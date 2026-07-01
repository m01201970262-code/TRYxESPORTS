$root = 'C:\Users\Mohanad\Desktop\tryxesports-site'
$prefix = 'http://127.0.0.1:8000/'
$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add($prefix)
$listener.Start()

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $path = $context.Request.Url.AbsolutePath
        if ($path -eq '/' -or $path -eq '') {
            $path = '/index.html'
        }

        $relativePath = $path.TrimStart('/')
        $fullPath = Join-Path $root $relativePath

        if ([System.IO.File]::Exists($fullPath)) {
            $extension = [System.IO.Path]::GetExtension($fullPath)
            $contentType = switch ($extension) {
                '.html' { 'text/html; charset=utf-8' }
                '.css' { 'text/css; charset=utf-8' }
                '.js' { 'application/javascript; charset=utf-8' }
                '.png' { 'image/png' }
                '.jpg' { 'image/jpeg' }
                '.jpeg' { 'image/jpeg' }
                '.svg' { 'image/svg+xml' }
                default { 'application/octet-stream' }
            }

            $bytes = [System.IO.File]::ReadAllBytes($fullPath)
            $context.Response.ContentType = $contentType
            $context.Response.ContentLength64 = $bytes.Length
            $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
        }
        else {
            $context.Response.StatusCode = 404
            $msg = [System.Text.Encoding]::UTF8.GetBytes('Not Found')
            $context.Response.ContentType = 'text/plain; charset=utf-8'
            $context.Response.ContentLength64 = $msg.Length
            $context.Response.OutputStream.Write($msg, 0, $msg.Length)
        }

        $context.Response.Close()
    }
    catch {
        break
    }
}

$listener.Stop()
$listener.Close()
