//! # musix
//! A rust music player library for esoteric formats
//!
//! Used libsidplay, UADE, GME, Openmpt etc to play a multitude of music
//! formats from old computers and consoles.
//!
//! <https://github.com/sasq64/musicplayer>
//!
//!
use std::error::Error;
use std::ffi::CStr;
use std::ffi::CString;
use std::ffi::NulError;
use std::fmt::Display;
use std::os::raw::c_char;
use std::os::raw::c_void;
use std::path::Path;

extern "C" {
    fn free(__ptr: *mut ::std::os::raw::c_void);
}

extern "C" {
    fn musix_create(data_dir: *const c_char) -> i32;
    fn musix_find_plugin(music_file: *const c_char) -> *mut c_void;
    fn musix_plugin_create_player(plugin: *mut c_void, music_file: *const c_char) -> *mut c_void;
    fn musix_player_get_meta(player: *const c_void, what: *const c_char) -> *const c_char;
    fn musix_player_get_samples(player: *const c_void, target: *mut i16, size: i32) -> i32;
    fn musix_player_seek(player: *const c_void, song: i32, seconds: i32);
    fn musix_player_destroy(player: *const c_void);
    fn musix_get_changed_meta(player: *const c_void) -> *const c_char;
    fn musix_get_error() -> *const c_char;
}

#[derive(Debug)]
pub struct MusicError {
    msg: String,
}

impl Display for MusicError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.msg)
    }
}

impl Error for MusicError {}

impl From<NulError> for MusicError {
    fn from(_value: NulError) -> Self {
        MusicError {
            msg: "NULL".to_string(),
        }
    }
}

pub struct ChipPlayer {
    player: *mut c_void,
}

impl ChipPlayer {
    pub fn new() -> ChipPlayer {
        ChipPlayer {
            player: std::ptr::null_mut(),
        }
    }

    /// Get the value of some meta data, as string
    pub fn get_meta_string(&mut self, what: &str) -> Option<String> {
        unsafe {
            let cwhat = CString::new(what).unwrap();
            let cptr = musix_player_get_meta(self.player, cwhat.as_ptr());
            if cptr.is_null() {
                return None;
            }
            let meta = CStr::from_ptr(cptr).to_string_lossy().into_owned();
            free(cptr as *mut c_void);
            Some(meta)
        }
    }

    /// Get the name of any changed meta data.
    pub fn get_changed_meta(&mut self) -> Option<String> {
        unsafe {
            let cptr = musix_get_changed_meta(self.player);
            if cptr.is_null() {
                return None;
            }

            let meta = CStr::from_ptr(cptr).to_string_lossy().into_owned();
            let res = Some(meta);
            free(cptr as *mut c_void);
            res
        }
    }

    /// Get samples for the current song. Returns number of samples actually rendered.
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
    /// Seek to a certain song and/or a certain offset in song (often not supported).
    pub fn seek(&mut self, song: i32, seconds: i32) {
        unsafe {
            musix_player_seek(self.player, song, seconds);
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

//unsafe impl Send for ChipPlayer {}

/// Load a song file
pub fn load_song(song_file: &str) -> Result<ChipPlayer, MusicError> {
    let music_file = CString::new(song_file).unwrap();
    unsafe {
        let plugin = musix_find_plugin(music_file.as_ptr());
        if plugin.is_null() {
            return Err(MusicError {
                msg: "Could not find a plugin for file.".to_string(),
            });
        }
        let player = musix_plugin_create_player(plugin, music_file.as_ptr());
        if plugin.is_null() {
            return Err(MusicError {
                msg: "Could not play file using plugin.".to_string(),
            });
        }
        Ok(ChipPlayer { player })
    }
}

/// Initialize musix. Must be given a path to the `data/` folder that contains bioses and
/// other additional files required for some formats to play correctly.
pub fn init(path: &Path) -> Result<(), MusicError> {
    let s = path.to_string_lossy();
    let data_dir = CString::new(s.as_ref())?;
    unsafe {
        if musix_create(data_dir.as_ptr()) != 0 {
            let err = musix_get_error();
            let cs = CStr::from_ptr(err).to_str().unwrap();
            return Err(MusicError {
                msg: cs.to_string(),
            });
        }
    }
    Ok(())
}

#[cfg(test)]
mod tests {

    #[test]
    fn it_works() {}
}
