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
use std::ffi::c_void;
use std::ffi::CStr;
use std::ffi::CString;
use std::ffi::NulError;
use std::fmt::Display;
use std::os::raw::c_char;
use std::path::Path;

extern "C" {
    fn free(__ptr: *mut ::std::os::raw::c_void);
}

#[repr(C)]
struct IdResult {
    pub title: *const c_char,
    pub game: *const c_char,
    pub composer: *const c_char,
    pub format: *const c_char,
    pub length: i32,
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
    fn musix_identify_file(music_file: *const c_char, ext: *const c_char) -> *const IdResult;
}

/// Represents a musix error
#[derive(Debug, Clone, PartialEq)]
pub struct MusicError {
    pub msg: String,
}

impl Display for MusicError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.msg)
    }
}

impl From<MusicError> for String {
    fn from(val: MusicError) -> Self {
        val.msg
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

/// A loaded song.
#[derive(Debug)]
pub struct ChipPlayer {
    player: *mut c_void,
}

unsafe impl Send for ChipPlayer {}
unsafe impl Sync for ChipPlayer {}

/// Interface to a loaded song.
impl ChipPlayer {
    /// Get the value of some meta data, as string
    pub fn get_meta_string(&mut self, what: &str) -> Option<String> {
        if self.player.is_null() {
            return None;
        }

        let cwhat = CString::new(what).unwrap();
        unsafe {
            let cptr = musix_player_get_meta(self.player, cwhat.as_ptr());
            if cptr.is_null() {
                return None;
            }
            let meta = CStr::from_ptr(cptr).to_string_lossy().into_owned();
            free(cptr as *mut c_void);
            Some(meta)
        }
    }

    /// Get the name of next changed meta data, if any.
    pub fn get_changed_meta(&mut self) -> Option<String> {
        if self.player.is_null() {
            return None;
        }
        unsafe {
            let cptr = musix_get_changed_meta(self.player);
            if cptr.is_null() {
                return None;
            }

            let meta = CStr::from_ptr(cptr).to_string_lossy().into_owned();
            free(cptr as *mut c_void);
            Some(meta)
        }
    }

    /// Get samples for the current song. Returns number of samples actually rendered.
    /// Format is always interleaved stereo @ 44100 Hz
    pub fn get_samples(&mut self, target: &mut [i16]) -> usize {
        if self.player.is_null() {
            0
        } else {
            let size = target.len() as i32;
            let rc = unsafe { musix_player_get_samples(self.player, target.as_mut_ptr(), size) };
            if rc < 0 {
                0
            } else {
                rc as usize
            }
        }
    }
    /// Seek to a certain song and/or a certain offset in song (often not supported).
    pub fn seek(&self, song: i32, seconds: i32) {
        if self.player.is_null() {
            return;
        }
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

#[derive(Default, Debug, Clone)]
pub struct SongInfo {
    pub title: String,
    pub game: String,
    pub composer: String,
    pub format: String,
}

/// Try to identify a song file, returning meta data if successful.
pub fn identify_song(song_file: &Path) -> Option<SongInfo> {
    let s = song_file.to_string_lossy();
    let music_file = CString::new(s.as_ref()).unwrap();
    unsafe {
        let ptr = musix_identify_file(music_file.as_ptr(), std::ptr::null());
        if ptr.is_null() {
            return None;
        }
        let info = SongInfo {
            title: CStr::from_ptr((*ptr).title).to_string_lossy().into(),
            game: CStr::from_ptr((*ptr).game).to_string_lossy().into(),
            composer: CStr::from_ptr((*ptr).composer).to_string_lossy().into(),
            format: CStr::from_ptr((*ptr).format).to_string_lossy().into(),
        };
        free(ptr as *mut c_void);
        Some(info)
    }
}
/// Load a song file
pub fn load_song(song_file: &Path) -> Result<ChipPlayer, MusicError> {
    let s = song_file.to_string_lossy();
    let music_file = CString::new(s.as_ref())?;
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
    use std::path::Path;

    use crate::*;

    #[test]
    fn load_song_works() {
        init(Path::new("init")).unwrap();
        let mut song = load_song(Path::new(
            "music/Martin Galway - Ultima Runes of Virtue II.gbs",
        ))
        .unwrap();
        let mut target = [0; 1024];
        let count = song.get_samples(&mut target);
        assert!(count == 1024);
    }

    #[test]
    fn identify_file_works() {
        let info = identify_song(Path::new("music/Castlevania.nsfe")).unwrap();
        println!("INFO {:?} {:?}", info.game, info.composer);
        println!("TITLE '{}'", info.game.to_str().unwrap());
        assert!(info.game.to_str().unwrap() == "Castlevania");
    }
}
