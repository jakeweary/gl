const c = @import("../c.zig");
const std = @import("std");

pub const callbacks = @import("callbacks.zig");
pub const debug = @import("debug.zig");
pub const Shader = @import("Shader.zig");
pub const Program = @import("Program.zig");
pub const ProgramBuilder = @import("ProgramBuilder.zig");
pub const log = std.log.scoped(.gl);

// ---

fn ReturnTypeOf(comptime method: @Type(.EnumLiteral)) type {
  const T = @TypeOf(@field(c, "gl" ++ @tagName(method)));
  return @typeInfo(T).Fn.return_type.?;
}

pub fn call(comptime method: @Type(.EnumLiteral), args: anytype) !ReturnTypeOf(method) {
  const result = @call(.{}, @field(c, "gl" ++ @tagName(method)), args);
  try debug.checkError();
  return result;
}

// ---

pub fn textureClampToEdges() void {
  c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_S, c.GL_CLAMP_TO_EDGE);
  c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_WRAP_T, c.GL_CLAMP_TO_EDGE);
}

pub fn textureFilterNearest() void {
  c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_NEAREST);
  c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_NEAREST);
}

pub fn textureFilterLinear() void {
  c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MIN_FILTER, c.GL_LINEAR);
  c.glTexParameteri(c.GL_TEXTURE_2D, c.GL_TEXTURE_MAG_FILTER, c.GL_LINEAR);
}

// ---

pub fn joinShaderSources(allocator: std.mem.Allocator, sources: []const []const u8) ![]const u8 {
  var joined = std.ArrayList(u8).init(allocator);
  defer joined.deinit();

  try joined.appendSlice("#version 460\n");
  for (sources) |source| {
    try joined.append('\n');
    try joined.appendSlice(source);
  }

  return joined.toOwnedSlice();
}
