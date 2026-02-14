using System.Text;
using FixFlow.API.Middleware;
using FixFlow.Infrastructure.Data;
using FixFlow.Tests.TestSupport;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;

namespace FixFlow.Tests.API;

public class AuthRefreshAndMiddlewareTests
{
    [Fact]
    public async Task AuthService_Refresh_ThrowsNotSupportedException()
    {
        var dbPath = Path.Combine(Path.GetTempPath(), $"fixflow-tests-{Guid.NewGuid():N}.db");
        await using var context = new FixFlowDbContext(TestFixtureFactory.CreateSqliteOptions(dbPath));
        await context.Database.EnsureCreatedAsync();
        var authService = TestFixtureFactory.CreateAuthService(context);

        var exception = await Assert.ThrowsAsync<NotSupportedException>(
            () => authService.RefreshAsync("dummy-token"));

        Assert.Equal("Osvjezavanje sesije trenutno nije podrzano. Prijavite se ponovo.", exception.Message);
    }

    [Fact]
    public async Task ExceptionMiddleware_MapsNotSupported_To501WithMessage()
    {
        const string expectedMessage = "Osvjezavanje sesije trenutno nije podrzano. Prijavite se ponovo.";

        var middleware = new ExceptionHandlerMiddleware(
            _ => throw new NotSupportedException(expectedMessage),
            NullLogger<ExceptionHandlerMiddleware>.Instance);

        var context = new DefaultHttpContext();
        context.Response.Body = new MemoryStream();

        await middleware.InvokeAsync(context);

        context.Response.Body.Position = 0;
        var responseBody = await new StreamReader(context.Response.Body, Encoding.UTF8).ReadToEndAsync();

        Assert.Equal(501, context.Response.StatusCode);
        Assert.Contains(expectedMessage, responseBody, StringComparison.Ordinal);
    }
}
