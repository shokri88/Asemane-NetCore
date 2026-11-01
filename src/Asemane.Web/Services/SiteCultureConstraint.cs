using Microsoft.AspNetCore.Routing;
namespace Asemane.Web.Services;
public class SiteCultureConstraint : IRouteConstraint
{
    public bool Match(HttpContext? httpContext, IRouter? route, string routeKey, RouteValueDictionary values, RouteDirection routeDirection)
        => values.TryGetValue(routeKey,out var value) && Languages.IsEnabled(value?.ToString() ?? "");
}
