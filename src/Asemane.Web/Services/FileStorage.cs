using System.Buffers.Binary;
namespace Asemane.Web.Services;
public class FileStorage
{
    public string Root { get; }
    public long MaximumBytes { get; }
    public FileStorage(IConfiguration config, IWebHostEnvironment env)
    {
        var root = config["Storage:RootPath"] ?? "App_Data/Uploads";
        Root = Path.GetFullPath(Path.IsPathRooted(root) ? root : Path.Combine(env.ContentRootPath, root));
        MaximumBytes = config.GetValue<long>("Storage:MaxFileBytes", 8 * 1024 * 1024);
        Directory.CreateDirectory(Root);
    }
    public static (string Extension, string Mime)? Detect(ReadOnlySpan<byte> header)
    {
        if (header.Length >= 12 && header[0] == 0xff && header[1] == 0xd8 && header[2] == 0xff) return (".jpg", "image/jpeg");
        if (header.Length >= 24 && header[..8].SequenceEqual(new byte[] {137,80,78,71,13,10,26,10}) && header.Slice(12,4).SequenceEqual("IHDR"u8))
        {
            var width = BinaryPrimitives.ReadUInt32BigEndian(header.Slice(16,4));
            var height = BinaryPrimitives.ReadUInt32BigEndian(header.Slice(20,4));
            if (width > 0 && height > 0 && (ulong)width * height <= 80000000) return (".png", "image/png");
        }
        if (header.Length >= 16 && header[..4].SequenceEqual("RIFF"u8) && header.Slice(8,4).SequenceEqual("WEBP"u8)) return (".webp", "image/webp");
        return null;
    }
    public async Task<(string Name, string Mime, long Bytes)> SaveAsync(IFormFile file, CancellationToken ct)
    {
        if (file.Length <= 0 || file.Length > MaximumBytes) throw new InvalidDataException("حجم تصویر باید بین یک بایت و ۸ مگابایت باشد.");
        await using var input = file.OpenReadStream();
        var header = new byte[32];
        var read = await input.ReadAtLeastAsync(header, 16, false, ct);
        var format = Detect(header.AsSpan(0,read)) ?? throw new InvalidDataException("فقط تصویر JPEG، PNG و WebP معتبر پذیرفته می‌شود.");
        var suppliedExtension = Path.GetExtension(file.FileName).ToLowerInvariant();
        if (!(suppliedExtension == format.Extension || (suppliedExtension == ".jpeg" && format.Extension == ".jpg")))
            throw new InvalidDataException("پسوند فایل با نوع تصویر هماهنگ نیست.");
        var name = Guid.NewGuid().ToString("N") + format.Extension;
        var destination = Path.Combine(Root, name);
        try
        {
            await using var output = new FileStream(destination, FileMode.CreateNew, FileAccess.Write, FileShare.None);
            await output.WriteAsync(header.AsMemory(0, read), ct);
            var total = (long)read;
            var buffer = new byte[81920];
            int count;
            while ((count = await input.ReadAsync(buffer, ct)) > 0)
            {
                total += count;
                if (total > MaximumBytes) throw new InvalidDataException("حجم تصویر بیش از حد مجاز است.");
                await output.WriteAsync(buffer.AsMemory(0,count), ct);
            }
            return (name, format.Mime, total);
        }
        catch { File.Delete(destination); throw; }
    }
    public string GetPath(string storedName)
    {
        if (Path.GetFileName(storedName) != storedName) throw new InvalidDataException("Invalid stored filename.");
        return Path.Combine(Root, storedName);
    }
    public void Delete(string storedName) => File.Delete(GetPath(storedName));
}
