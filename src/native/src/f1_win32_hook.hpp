#ifndef F1_WIN32_HOOK_H
#define F1_WIN32_HOOK_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/image.hpp>
#include <godot_cpp/core/class_db.hpp>

#ifdef WIN32
#include <windows.h>
#endif

namespace godot {

class F1Win32Hook : public Node {
    GDCLASS(F1Win32Hook, Node)

private:
    float alpha_threshold = 0.1f;
    bool passthrough_enabled = true;
    Ref<Image> hit_map;
    HWND hwnd = NULL;
    WNDPROC original_wndproc = NULL;

    static LRESULT CALLBACK wnd_proc(HWND hwnd, UINT msg, WPARAM wparam, LPARAM lparam);

protected:
    static void _bind_methods();

public:
    F1Win32Hook();
    ~F1Win32Hook();

    void _ready() override;
    void _exit_tree() override;

    void set_passthrough_enabled(bool enabled);
    bool is_passthrough_enabled() const;

    void set_alpha_threshold(float threshold);
    float get_alpha_threshold() const;

    void update_hit_map(Ref<Image> p_image);

    LRESULT handle_message(UINT msg, WPARAM wparam, LPARAM lparam);
};

}

#endif