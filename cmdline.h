#pragma once

#include "mold.h"

namespace mold {

template <typename C>
std::vector<std::string_view>
read_response_file(C &ctx, std::string_view path) {
  std::vector<std::string_view> vec;
  MappedFile<C> *mf = MappedFile<C>::must_open(ctx, std::string(path));
  u8 *data = mf->data;

  auto read_quoted = [&](i64 i, char quote) {
    std::string buf;
    while (i < mf->size && data[i] != quote) {
      if (data[i] == '\\') {
        buf.append(1, data[i + 1]);
        i += 2;
      } else {
        buf.append(1, data[i++]);
      }
    }
    if (i >= mf->size)
      Fatal(ctx) << path << ": premature end of input";
    vec.push_back(save_string(ctx, buf));
    return i + 1;
  };

  auto read_unquoted = [&](i64 i) {
    std::string buf;
    while (i < mf->size && !isspace(data[i]))
      buf.append(1, data[i++]);
    vec.push_back(save_string(ctx, buf));
    return i;
  };

  for (i64 i = 0; i < mf->size;) {
    if (isspace(data[i]))
      i++;
    else if (data[i] == '\'')
      i = read_quoted(i + 1, '\'');
    else if (data[i] == '\"')
      i = read_quoted(i + 1, '\"');
    else
      i = read_unquoted(i);
  }
  return vec;
}

// Replace "@path/to/some/text/file" with its file contents.
template <typename C>
std::vector<std::string_view> expand_response_files(C &ctx, char **argv) {
  std::vector<std::string_view> vec;
  for (i64 i = 0; argv[i]; i++) {
    if (argv[i][0] == '@')
      append(vec, read_response_file(ctx, argv[i] + 1));
    else
      vec.push_back(argv[i]);
  }
  return vec;
}

} // namespace mold
