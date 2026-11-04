#pragma once

// Small ATL string-conversion compatibility layer for the Windows secure
// storage plugin. The plugin only uses CA2W::m_psz and CW2A conversion here.
#include <windows.h>
#include <string>

class CA2W {
 private:
  std::wstring value_;

 public:
  explicit CA2W(const char* value) : value_(ToWide(value)), m_psz(value_.data()) {}
  LPWSTR m_psz;

 private:
  static std::wstring ToWide(const char* value) {
    if (value == nullptr || *value == '\0') return std::wstring();
    const int size = MultiByteToWideChar(CP_ACP, 0, value, -1, nullptr, 0);
    if (size <= 1) return std::wstring();
    std::wstring result(static_cast<size_t>(size), L'\0');
    MultiByteToWideChar(CP_ACP, 0, value, -1, result.data(), size);
    result.resize(static_cast<size_t>(size - 1));
    return result;
  }
};

class CW2A {
 public:
  explicit CW2A(LPCWSTR value) : value_(ToNarrow(value)) {}
  operator const char*() const { return value_.c_str(); }

 private:
  static std::string ToNarrow(LPCWSTR value) {
    if (value == nullptr || *value == L'\0') return std::string();
    const int size = WideCharToMultiByte(CP_ACP, 0, value, -1, nullptr, 0, nullptr, nullptr);
    if (size <= 1) return std::string();
    std::string result(static_cast<size_t>(size), '\0');
    WideCharToMultiByte(CP_ACP, 0, value, -1, result.data(), size, nullptr, nullptr);
    result.resize(static_cast<size_t>(size - 1));
    return result;
  }
  std::string value_;
};
