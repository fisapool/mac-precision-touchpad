// This file is used to suppress warnings globally for the project
// during the development/debugging phase
using System.Diagnostics.CodeAnalysis;

#pragma warning disable CS8618 // Non-nullable field must contain a non-null value when exiting constructor
#pragma warning disable CS8600 // Converting null literal or possible null value to non-nullable type
#pragma warning disable CS8602 // Dereference of a possibly null reference
#pragma warning disable CS8603 // Possible null reference return
#pragma warning disable CS8625 // Cannot convert null literal to non-nullable reference type

// Enable this only when using Windows-specific APIs (Registry, ServiceController)
#pragma warning disable CA1416 // Validate platform compatibility 