#include "win32_window.h"
#include <dwmapi.h>
#include <flutter_windows.h>

namespace {
constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";
LRESULT CALLBACK WndProc(HWND const window, UINT const message,
                         WPARAM const wparam,
                         LPARAM const lparam) noexcept;
}  // namespace

Win32Window::Win32Window() {
  RegisterWindowClass(kWindowClassName);
}

Win32Window::~Win32Window() {
  Destroy();
}

bool Win32Window::Create(const std::wstring& title, const Point& origin,
                         const Size& size) {
  Destroy();
  const wchar_t* window_class = kWindowClassName;
  DWORD window_ex_style = WS_EX_APPWINDOW;
  DWORD window_style    = WS_OVERLAPPEDWINDOW;
  HWND window = CreateWindowEx(
      window_ex_style, window_class, title.c_str(), window_style,
      Scale(origin.x, 1.0), Scale(origin.y, 1.0),
      Scale(size.width, 1.0), Scale(size.height, 1.0),
      nullptr, nullptr, GetModuleHandle(nullptr), this);
  if (!window) return false;
  window_handle_ = window;
  return OnCreate();
}

bool Win32Window::Show() {
  return ShowWindow(window_handle_, SW_SHOWNORMAL);
}

void Win32Window::Destroy() {
  OnDestroy();
  if (window_handle_) {
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
}

HWND Win32Window::GetHandle() { return window_handle_; }

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

bool Win32Window::OnCreate()  { return true; }
void Win32Window::OnDestroy() {}

void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, window_handle_);
  RECT frame = GetClientArea();
  MoveWindow(content, frame.left, frame.top, frame.right - frame.left,
             frame.bottom - frame.top, true);
}

LRESULT Win32Window::MessageHandler(HWND hwnd, UINT const message,
                                    WPARAM const wparam,
                                    LPARAM const lparam) noexcept {
  switch (message) {
    case WM_DESTROY:
      if (quit_on_close_) PostQuitMessage(0);
      return 0;
    case WM_SIZE:
      if (child_content_ != nullptr) {
        RECT frame = GetClientArea();
        MoveWindow(child_content_, frame.left, frame.top,
                   frame.right - frame.left, frame.bottom - frame.top, TRUE);
      }
      return 0;
    case WM_ACTIVATE:
      if (child_content_ != nullptr) SetFocus(child_content_);
      return 0;
  }
  return DefWindowProc(hwnd, message, wparam, lparam);
}

static int Scale(int source, double scale_factor) {
  return static_cast<int>(source * scale_factor);
}

static void RegisterWindowClass(const std::wstring& class_name) {
  WNDCLASS window_class{};
  window_class.hCursor       = LoadCursor(nullptr, IDC_ARROW);
  window_class.lpszClassName = class_name.c_str();
  window_class.style         = CS_HREDRAW | CS_VREDRAW;
  window_class.cbClsExtra    = 0;
  window_class.cbWndExtra    = 0;
  window_class.hInstance     = GetModuleHandle(nullptr);
  window_class.hIcon         = LoadIcon(window_class.hInstance, L"IDI_APP_ICON");
  window_class.hbrBackground = 0;
  window_class.lpszMenuName  = nullptr;
  window_class.lpfnWndProc   = Win32Window::WndProc;
  RegisterClass(&window_class);
}

LRESULT CALLBACK Win32Window::WndProc(HWND const window, UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    auto* cs = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(cs->lpCreateParams));
    auto* that = static_cast<Win32Window*>(cs->lpCreateParams);
    EnableNonClientDpiScaling(window);
    that->window_handle_ = window;
  } else if (Win32Window* that = reinterpret_cast<Win32Window*>(
                 GetWindowLongPtr(window, GWLP_USERDATA))) {
    return that->MessageHandler(window, message, wparam, lparam);
  }
  return DefWindowProc(window, message, wparam, lparam);
}
