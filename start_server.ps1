param(
    [int]$Port = 8000,
    [string]$Root = (Resolve-Path .).Path
)

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$Port/")
$listener.Prefixes.Add("http://127.0.0.1:$Port/")
$listener.Prefixes.Add("http://sachithananthamp.com:$Port/")
$listener.Start()
Write-Host "Serving $Root on http://localhost:$Port/ and http://sachithananthamp.com:$Port/"

while ($true) {
    $context = $listener.GetContext()
    $request = $context.Request
    $response = $context.Response

    try {
        $path = [System.Uri]::UnescapeDataString($request.Url.AbsolutePath)
        if ($path -eq "/") { $path = "/index.html" }

        $relativePath = $path.TrimStart("/")
        $fullPath = Join-Path $Root $relativePath
        $fullPath = [System.IO.Path]::GetFullPath($fullPath)

        if (-not $fullPath.StartsWith([System.IO.Path]::GetFullPath($Root))) {
            throw "Forbidden"
        }

        if ([System.IO.File]::Exists($fullPath)) {
            $content = [System.IO.File]::ReadAllBytes($fullPath)
            $extension = [System.IO.Path]::GetExtension($fullPath)
            $mime = switch ($extension) {
                ".html" { "text/html; charset=utf-8" }
                ".css" { "text/css; charset=utf-8" }
                ".js" { "application/javascript; charset=utf-8" }
                ".json" { "application/json; charset=utf-8" }
                ".png" { "image/png" }
                ".jpg" { "image/jpeg" }
                ".jpeg" { "image/jpeg" }
                ".svg" { "image/svg+xml" }
                default { "application/octet-stream" }
            }
            $response.ContentType = $mime
            $response.ContentLength64 = $content.Length
            $response.OutputStream.Write($content, 0, $content.Length)
        }
        else {
            $response.StatusCode = 404
            $body = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
            $response.ContentType = "text/plain; charset=utf-8"
            $response.ContentLength64 = $body.Length
            $response.OutputStream.Write($body, 0, $body.Length)
        }
    }
    catch {
        $response.StatusCode = 403
        $body = [System.Text.Encoding]::UTF8.GetBytes("403 Forbidden")
        $response.ContentType = "text/plain; charset=utf-8"
        $response.ContentLength64 = $body.Length
        $response.OutputStream.Write($body, 0, $body.Length)
    }
    finally {
        $response.Close()
    }
}
