pub mod musix {

    use std::ffi::CStr;
    use std::ffi::CString;
    use std::os::raw::c_char;
    use std::os::raw::c_void;

    extern "C" {
        pub fn free(__ptr: *mut ::std::os::raw::c_void);
    }

    extern "C" {
        fn musix_create(data_dir: *const c_char) -> i32;
        fn musix_find_plugin(music_file: *const c_char) -> *mut c_void;
        fn musix_plugin_create_player(plugin: *mut c_void, music_file: *const c_char) -> *mut c_void;
        fn musix_player_get_meta(player: *const c_void, what: *const c_char) -> *const c_char;
        fn musix_player_get_samples(player: *const c_void, target: *mut i16, size: i32) -> i32;

        fn musix_player_seek(player: *const c_void, song: i32, seconds: i32);

        fn musix_player_destroy(player: *const c_void);
    }

    pub struct ChipPlayer {
        player: *mut c_void,
    }

    impl ChipPlayer {
        pub fn get_meta(&mut self, what: &str) -> String {
            unsafe {
                let cptr = musix_player_get_meta(self.player, CString::new(what).unwrap().as_ptr());
                let meta = CStr::from_ptr(cptr).to_string_lossy().into_owned();
                free(cptr as *mut c_void);
                meta
            }
        }

        pub fn get_samples(&mut self, target: &mut [i16]) -> usize {
            unsafe {
                if self.player.is_null() {
                    0
                } else {
                    let size = target.len() as i32;
                    musix_player_get_samples(self.player, target.as_mut_ptr(), size) as usize
                }
            }
        }
        pub fn seek(&mut self, song: i32, seconds: i32) {
            unsafe {
                musix_player_seek(self.player, song, seconds);
            }
        }

        pub fn new() -> ChipPlayer {
            ChipPlayer {
                player: std::ptr::null_mut(),
            }
        }
    }

    impl Drop for ChipPlayer {
        fn drop(&mut self) {
            if !self.player.is_null() {
                unsafe { musix_player_destroy(self.player) }
            }
        }
    }

    unsafe impl Send for ChipPlayer {}

    pub fn play_song(song_file: &str) -> ChipPlayer {
        let music_file = CString::new(song_file).unwrap();
        unsafe {
            let plugin = musix_find_plugin(music_file.as_ptr());
            let player = musix_plugin_create_player(plugin, music_file.as_ptr());
            ChipPlayer { player }
        }
    }

    pub fn init(path: &str) {
        let data_dir = CString::new(path).unwrap();
        unsafe {
            musix_create(data_dir.as_ptr());
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
    }
}
