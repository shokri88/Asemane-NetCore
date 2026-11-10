"""Compare rendered public pages with the supplied template; never use app containers as the reference."""
import argparse, hashlib, json, subprocess
from copy import deepcopy
from pathlib import Path
from lxml import html, etree
from PIL import Image, ImageChops
from playwright.sync_api import sync_playwright

PAGES = {
    'home': ('/en', 'index.html'), 'about': ('/en/about', 'about.html'),
    'contact': ('/en/contact', 'contact.html'), 'projects': ('/en/projects', 'workgrid.html'),
    'project': ('/en/projects/garden-house', 'workdet.html'), 'blog': ('/en/journal', 'blog.html'),
    'article': ('/en/journal/studio-news', 'blogdet.html'),
    'page': ('/en/pages/studio-story', 'blogdet.html'), 'team': ('/en/team/architect-1', 'blogdet.html'),
}

def classes(n): return (n.get('class') or '').split()
def find(n, cls): return [x for x in n.iter() if cls in classes(x)]
def children(n): return [x for x in n if isinstance(x.tag, str)]
def trim(n, count):
    for child in children(n)[count:]: n.remove(child)
def replace_contents(a, b):
    a.text = b.text
    for child in list(a): a.remove(child)
    for child in b: a.append(deepcopy(child))
def shape(n):
    if n.tag == 'h4': return ('h4', classes(n), [])  # Title links are data; typography is still compared in pixels.
    c = [x for x in classes(n) if not x.startswith('p_f_')]
    if 'comment' in c: c = [x for x in c if x not in ['alt','even','odd'] and not x.startswith('thread')]
    return (n.tag, c, [shape(x) for x in children(n)])
def data(a, b):
    a.text, a.tail = b.text, b.tail
    for key in ['src','alt','href','id','data-filter','data-url','data-next-link','data-max-page','data-start-page']:
        if key in b.attrib: a.set(key,b.get(key))
    if a.tag == 'img' and a.get('data-lazy-src'):
        if b.get('data-lazy-src'): a.set('data-lazy-src', b.get('data-lazy-src'))
        else: a.attrib.pop('data-lazy-src')
    if a.tag == 'h4':
        # Keep the template's plain text title. A dynamic anchor must have the same appearance.
        a.text = b.text_content()
        for child in list(a): a.remove(child)
        return
    for aa,bb in zip(children(a),children(b)): data(aa,bb)

def reference(name, source, actual, shared_header):
    a = html.fromstring(source); b = html.fromstring(actual)
    for tree in [a,b]:
        for comment in tree.xpath('//comment()'): comment.getparent().remove(comment)
    # Prior explicit request: use one shared five-item header everywhere.
    header = a.find('.//header'); normalized_header=deepcopy(shared_header)
    for item in list(find(normalized_header,'main-menu')[0]):
        if 'Project Details' in item.text_content(): item.getparent().remove(item)
    header.getparent().replace(header,normalized_header)
    assets = {}
    for tag,attr in [('link','href'),('script','src')]:
        original = [x.get(attr) for x in a.iter(tag) if x.get(attr) and (tag != 'link' or x.get('rel') == 'stylesheet')]
        rendered = [x.get(attr).removeprefix('/template/') for x in b.iter(tag) if x.get(attr) and (tag != 'link' or x.get('rel') == 'stylesheet') and x.get(attr).startswith('/template/')]
        assert original == rendered, (name, 'vendor order', original,rendered)
        assets[tag] = original
    # Additional invisible SEO heading/pagination has no counterpart in the original template.
    for n in list(b.iter()):
        if 'sr-only' in classes(n): n.getparent().remove(n)
    # Normalize only repeat counts, content slots and metadata, never template layout containers.
    for cls in ['prague-dropdown-menu','js-load-more-block']:
        aa,bb = find(a,cls),find(b,cls)
        if aa and bb: trim(aa[0],len(children(bb[0])))
    if name == 'home':
        aa,bb = find(a,'swiper-wrapper')[0],find(b,'swiper-wrapper')[0]; trim(aa,len(children(bb)))
        for x,y in zip(find(a,'slide-category'),find(b,'slide-category')): replace_contents(x,y)
    if name in ['about','blog']:
        aa=find(a,'prague-comments-list')[0].find('ul');bb=find(b,'prague-comments-list')[0].find('ul');trim(aa,len(children(bb)))
    if name == 'contact': trim(find(a,'call')[0],len(children(find(b,'call')[0])))
    if name == 'project': trim(a.xpath('//*[@id="slides"]')[0],len(children(b.xpath('//*[@id="slides"]')[0])))
    for x,y in zip(find(a,'content'),find(b,'content')): replace_contents(x,y)
    # Original project header/preview images are data slots; some originals omit src until JS runs.
    for tree in [a,b]:
        for script in list(tree.iter('script')): script.getparent().remove(script)
        for loader in find(tree,'prague-loader'): loader.getparent().remove(loader)
    assert shape(a.find('body')) == shape(b.find('body')), (name, 'container tree or classes differ')
    data(a.find('body'),b.find('body'))
    for x in a.iter('link'):
        if x.get('href','').startswith(('css/','font-awesome/')): x.set('href','/template/'+x.get('href'))
    return etree.tostring(a,method='html',encoding='unicode'),etree.tostring(b,method='html',encoding='unicode'),assets

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--url',default='https://localhost:7445');parser.add_argument('--template',required=True,type=Path);parser.add_argument('--repo',required=True,type=Path);parser.add_argument('--output',required=True,type=Path);parser.add_argument('--chromium',default='/usr/bin/chromium');args=parser.parse_args();args.output.mkdir(parents=True,exist_ok=True)
    manifest=json.loads((args.repo/'docs/template-assets.sha256.json').read_text())
    for path,expected in manifest.items():
        actual=args.repo/'src/Asemane.Web/wwwroot/template'/path
        assert hashlib.sha256(actual.read_bytes()).hexdigest()==expected,('vendor checksum',path)
        assert actual.read_bytes()==(args.template/path).read_bytes(),('differs from upstream',path)
    results={'template_commit':subprocess.check_output(['git','-C',str(args.template),'rev-parse','HEAD'],text=True).strip(),'vendor_files_verified':len(manifest),'pages':{},'no_reference':{}}
    with sync_playwright() as p:
        browser=p.chromium.launch(executable_path=args.chromium,headless=True,args=['--no-sandbox'])
        context=browser.new_context(ignore_https_errors=True,viewport={'width':1440,'height':1000})
        context.route('**/*',lambda r:r.continue_() if r.request.url.startswith(args.url) else r.abort())
        page=context.new_page()
        for name,(path,sourcefile) in PAGES.items():
            response=page.request.get(args.url+path);assert response.status==200,(path,response.status)
            raw=response.text();(args.output/(name+'-rendered.html')).write_text(raw)
            try: ref,actual,assets=reference(name,(args.template/sourcefile).read_text(),raw,html.fromstring((args.template/'index.html').read_text()).find('.//header'))
            except AssertionError as error:
                results['pages'][name]={'structural_error':str(error)};continue
            (args.output/(name+'-reference.html')).write_text(ref);(args.output/(name+'-actual.html')).write_text(actual)
            def serve(body):
                return lambda route: route.fulfill(body=body,content_type='text/html')
            context.route('**/__audit-ref-'+name,serve(ref))
            context.route('**/__audit-actual-'+name,serve(actual))
            matrix=[]
            for width,height in [(1440,1000),(768,1024),(390,844)]:
                page.set_viewport_size({'width':width,'height':height})
                for side in ['ref','actual']:
                    page.goto(args.url+'/__audit-'+side+'-'+name,wait_until='networkidle');page.mouse.move(0,0);page.screenshot(path=str(args.output/f'{name}-{side}-{width}.png'),full_page=True)
                a=Image.open(args.output/f'{name}-ref-{width}.png').convert('RGB');b=Image.open(args.output/f'{name}-actual-{width}.png').convert('RGB')
                bounds=ImageChops.difference(a,b).getbbox() if a.size==b.size else 'different dimensions'
                matrix.append({'width':width,'identical':bounds is None,'bounds':bounds})
            results['pages'][name]={'template':sourcefile,'structure':'match','vendor_order':'match','screenshots':matrix}
        # Error/admin routes have no supplied upstream HTML. Check behavior and responsive layout without claiming parity.
        for path,status in [('/en/missing',404),('/status/404',404),('/error',500),('/admin/account/login',200)]:
            response=page.goto(args.url+path,wait_until='networkidle');assert response.status==status,(path,response.status)
            assert page.locator('h1').count()==1,path
            assert page.locator('meta[name="robots"]').get_attribute('content').startswith('noindex'),path
            results['no_reference'][path]={'status':status,'main_heading':'one','indexing':'disabled'}
        browser.close()
    (args.output/'results.json').write_text(json.dumps(results,ensure_ascii=False,indent=2));print(json.dumps({'pages':{k:r.get('screenshots',r) for k,r in results['pages'].items()},'vendor_files_verified':len(manifest),'no_reference_routes':list(results['no_reference'])},ensure_ascii=False,indent=2))
    assert all('structural_error' not in r and all(s['identical'] for s in r['screenshots']) for r in results['pages'].values()),'Template parity differences found; see results.json'
if __name__=='__main__': main()
