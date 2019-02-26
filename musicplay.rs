use std::ffi::CString;
use std::ffi::CStr;
use std::os::raw::c_char;
use std::os::raw::c_void;

#[link(name="musix")]
extern {
    fn musix_create(dataDir: *const c_char) -> i32;
    fn musix_find_plugin(musicFile: *const c_char) -> *mut c_void ;
    fn musix_plugin_create_player(plugin: *mut c_void, musicFile: *const c_char)
        -> *mut c_void;
    fn musix_player_get_meta(player: *mut c_void, what: *const c_char)
        -> *const c_char;
    fn musix_player_get_samples(player: *mut c_void, target: *mut i16, size: i32)
        -> i32;
    fn musix_player_destroy(player: *mut c_void);
}

extern {
    fn free(p: *mut c_void);
}

fn main() {
    let music_file = CString::new("music/Castlevania.nsfe").unwrap();
    let data_dir = CString::new("data").unwrap();

    let mut samples: [i16; 8192] = [0; 8192];

    unsafe {
        musix_create(data_dir.as_ptr());

        let plugin = musix_find_plugin(music_file.as_ptr());
        let player = musix_plugin_create_player(plugin, music_file.as_ptr());
        let cptr = musix_player_get_meta(player,
                                         CString::new("game").unwrap().as_ptr());  
        let title = CStr::from_ptr(cptr).to_string_lossy().into_owned().clone();

        free(cptr as *mut c_void);

        let count = musix_player_get_samples(player, samples.as_mut_ptr(), samples.len() as i32);

        println!("TITLE:{} {}", title, count);

        musix_player_destroy(player);

    }
}
