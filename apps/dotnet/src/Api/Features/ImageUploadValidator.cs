namespace Realworlddotnet.Api.Features;

public static class ImageUploadValidator
{
    public const long MaxFileSize = 5 * 1024 * 1024;

    public static async Task<string> ValidateAndGetExtensionAsync(
        IFormFile file,
        CancellationToken cancellationToken)
    {
        if (file.Length == 0)
        {
            throw new ProblemDetailsException(400, "The uploaded image is empty.");
        }

        if (file.Length > MaxFileSize)
        {
            throw new ProblemDetailsException(400, "Images must be 5 MB or smaller.");
        }

        var header = new byte[8];
        await using var input = file.OpenReadStream();
        var bytesRead = await input.ReadAsync(header.AsMemory(0, header.Length), cancellationToken);

        var isJpeg = bytesRead >= 3
            && header[0] == 0xFF
            && header[1] == 0xD8
            && header[2] == 0xFF;
        var isPng = bytesRead >= 8
            && header.AsSpan().SequenceEqual(new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A });

        return (isJpeg, isPng) switch
        {
            (true, false) => ".jpg",
            (false, true) => ".png",
            _ => throw new ProblemDetailsException(400, "Only valid JPEG and PNG images are accepted.")
        };
    }
}
