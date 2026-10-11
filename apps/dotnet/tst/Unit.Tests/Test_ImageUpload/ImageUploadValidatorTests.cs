using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using Hellang.Middleware.ProblemDetails;
using Microsoft.AspNetCore.Http;
using Realworlddotnet.Api.Features;
using Xunit;

namespace Unit.Tests.Test_ImageUpload;

public class ImageUploadValidatorTests
{
    [Fact]
    public async Task AcceptsPngByFileSignature()
    {
        var bytes = new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00 };
        var file = CreateFile(bytes, "image.txt");

        var extension = await ImageUploadValidator.ValidateAndGetExtensionAsync(file, CancellationToken.None);

        extension.Should().Be(".png");
    }

    [Fact]
    public async Task AcceptsJpegByFileSignature()
    {
        var bytes = new byte[] { 0xFF, 0xD8, 0xFF, 0x00 };
        var file = CreateFile(bytes, "image.bin");

        var extension = await ImageUploadValidator.ValidateAndGetExtensionAsync(file, CancellationToken.None);

        extension.Should().Be(".jpg");
    }

    [Fact]
    public async Task RejectsAnExtensionOnlyImage()
    {
        var file = CreateFile("not an image"u8.ToArray(), "image.png");

        Func<Task> validate = async () =>
            await ImageUploadValidator.ValidateAndGetExtensionAsync(file, CancellationToken.None);

        await validate.Should().ThrowAsync<ProblemDetailsException>();
    }

    [Fact]
    public async Task RejectsImagesLargerThanFiveMegabytes()
    {
        var stream = new MemoryStream(new byte[] { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A });
        var file = new FormFile(stream, 0, ImageUploadValidator.MaxFileSize + 1, "file", "large.png");

        Func<Task> validate = async () =>
            await ImageUploadValidator.ValidateAndGetExtensionAsync(file, CancellationToken.None);

        await validate.Should().ThrowAsync<ProblemDetailsException>();
    }

    private static FormFile CreateFile(byte[] bytes, string fileName)
    {
        var stream = new MemoryStream(bytes);
        return new FormFile(stream, 0, bytes.Length, "file", fileName);
    }
}
