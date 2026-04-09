#include "f1_win32_hook.hpp"
#include <godot_cpp/classes/display_server.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

LRESULT CALLBACK F1Win32Hook::wnd_proc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam) {
    F1Win32Hook *hook = reinterpret_cast<F1Win32Hook *>(GetWindowLongPtr(hwnd, GWLP_USERDATA));
    if (hook && msg == WM_NCHITTEST) {
        return hook->handle_message(msg, wparam, lparam);
    }
    if (hook && hook->original_wndproc) {
        return CallWindowProc(hook->original_wndproc, hwnd, msg, wparam, lparam);
    }
    return DefWindowProc(hwnd, msg, wparam, lparam);
}

F1Win32Hook::F1Win32Hook() {}

F1Win32Hook::~F1Win32Hook() {}

void F1Win32Hook::_ready() {
    if (Engine::get_singleton()->is_editor_hint()) return;

#ifdef WIN32
    // 获取 Godot 窗口句柄 (Win32 平台)
    int64_t native_handle = DisplayServer::get_singleton()->window_get_native_handle(DisplayServer::WINDOW_HANDLE_HWND);
    hwnd = (HWND)native_handle;

    if (hwnd) {
        SetWindowLongPtr(hwnd, GWLP_USERDATA, (LONG_PTR)this);
        original_wndproc = (WNDPROC)SetWindowLongPtr(hwnd, GWLP_WNDPROC, (LONG_PTR)wnd_proc);
        UtilityFunctions::print("[F1] Win32 Hook Injected Successfully.");
    }
#endif
}

void F1Win32Hook::_exit_tree() {
#ifdef WIN32
    if (hwnd && original_wndproc) {
        SetWindowLongPtr(hwnd, GWLP_WNDPROC, (LONG_PTR)original_wndproc);
    }
#endif
}

LRESULT F1Win32Hook::handle_message(UINT msg, WPARAM wparam, LPARAM lparam) {
    if (msg == WM_NCHITTEST && passthrough_enabled && hit_map.is_valid()) {
        POINT pt = { LOWORD(lparam), HIWORD(lparam) };
        ScreenToClient(hwnd, &pt);

        int x = pt.x;
        int y = pt.y;

        if (x >= 0 && x < hit_map->get_width() && y >= 0 && y < hit_map->get_height()) {
            Color pixel = hit_map->get_pixel(x, y);
            if (pixel.a < alpha_threshold) {
                return HTTRANSPARENT; // 穿透
            }
        }
    }
    return CallWindowProc(original_wndproc, hwnd, msg, wparam, lparam);
}

void F1Win32Hook::set_passthrough_enabled(bool enabled) { passthrough_enabled = enabled; }
bool F1Win32Hook::is_passthrough_enabled() const { return passthrough_enabled; }

void F1Win32Hook::set_alpha_threshold(float threshold) { alpha_threshold = threshold; }
float F1Win32Hook::get_alpha_threshold() const { return alpha_threshold; }

void F1Win32Hook::update_hit_map(Ref<Image> p_image) {
    hit_map = p_image;
}

void F1Win32Hook::_bind_methods() {
    ClassDB::bind_method(D_METHOD("set_passthrough_enabled", "enabled"), &F1Win32Hook::set_passthrough_enabled);
    ClassDB::bind_method(D_METHOD("is_passthrough_enabled"), &F1Win32Hook::is_passthrough_enabled);
    ClassDB::bind_method(D_METHOD("set_alpha_threshold", "threshold"), &F1Win32Hook::set_alpha_threshold);
    ClassDB::bind_method(D_METHOD("get_alpha_threshold"), &F1Win32Hook::get_alpha_threshold);
    ClassDB::bind_method(D_METHOD("update_hit_map", "image"), &F1Win32Hook::update_hit_map);

    ADD_PROPERTY(PropertyInfo(Variant::BOOL, "passthrough_enabled"), "set_passthrough_enabled", "is_passthrough_enabled");
    ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "alpha_threshold"), "set_alpha_threshold", "get_alpha_threshold");
}