use std::{
    collections::{HashMap, VecDeque},
    path::{Path, PathBuf},
};

use claxon::FlacReader;

use crate::{MusicError, MusixPlayer};

/// A FLAC audio player using the claxon crate. Streams samples on-the-fly.
pub struct FlacPlayer {
    reader: FlacReader<std::fs::File>,
    decode_buf: Vec<i32>,
    buffer: Vec<i16>,
    buf_pos: usize,
    files: Vec<PathBuf>,
    meta: HashMap<String, String>,
    changed: VecDeque<String>,
}

unsafe impl Send for FlacPlayer {}
unsafe impl Sync for FlacPlayer {}

#[inline]
fn convert_sample(sample: i32, bits: u32) -> i16 {
    match bits {
        8 => (sample as i16) << 8,
        16 => sample as i16,
        24 => (sample >> 8) as i16,
        32 => (sample >> 16) as i16,
        _ => sample as i16,
    }
}

impl FlacPlayer {
    /// Decode the next FLAC frame into the interleaved stereo buffer.
    fn decode_next_frame(&mut self) -> bool {
        let decode_buf = std::mem::take(&mut self.decode_buf);
        let result = self.reader.blocks().read_next_or_eof(decode_buf);
        let block = match result {
            Ok(Some(block)) => block,
            Ok(None) => return false,
            Err(_) => return false,
        };

        let info = self.reader.streaminfo();
        let channels = info.channels;
        let bits = info.bits_per_sample;
        let frame_len = block.duration();

        self.buffer.clear();
        self.buf_pos = 0;
        self.buffer.reserve(frame_len as usize * 2);

        for i in 0..frame_len {
            let left = convert_sample(block.sample(0, i), bits);
            let right = if channels >= 2 {
                convert_sample(block.sample(1, i), bits)
            } else {
                left
            };
            self.buffer.push(left);
            self.buffer.push(right);
        }

        self.decode_buf = block.into_buffer();
        true
    }

    pub fn new(song_file: &Path) -> Result<FlacPlayer, MusicError> {
        let reader = FlacReader::open(song_file).map_err(|e| MusicError {
            msg: format!("Failed to open FLAC: {}", e),
        })?;
        let mut changed = VecDeque::new();

        let mut meta = HashMap::<String, String>::new();
        for (name, val) in reader.tags() {
            match name {
                "ARTIST" => {
                    meta.insert("composer".into(), val.into());
                    changed.push_back("composer".to_string());
                }
                "TITLE" => {
                    meta.insert("title".into(), val.into());
                    changed.push_back("title".to_string());
                }
                _ => {}
            }
        }

        Ok(FlacPlayer {
            reader,
            decode_buf: Vec::new(),
            buffer: Vec::new(),
            buf_pos: 0,
            files: vec![song_file.to_owned()],
            changed,
            meta,
        })
    }
}

impl MusixPlayer for FlacPlayer {
    fn get_changed_meta(&mut self) -> Option<String> {
        self.changed.pop_front()
    }

    fn get_meta_string(&mut self, what: &str) -> Option<String> {
        self.meta.get(what).cloned()
    }

    fn get_song_files(&self) -> &Vec<PathBuf> {
        &self.files
    }

    fn get_frequency(&self) -> u32 {
        self.reader.streaminfo().sample_rate
    }

    fn get_samples(&mut self, target: &mut [i16]) -> usize {
        let mut written = 0;

        while written < target.len() {
            let buf_remaining = self.buffer.len() - self.buf_pos;
            if buf_remaining > 0 {
                let n = (target.len() - written).min(buf_remaining);
                target[written..written + n]
                    .copy_from_slice(&self.buffer[self.buf_pos..self.buf_pos + n]);
                self.buf_pos += n;
                written += n;
            } else if !self.decode_next_frame() {
                break;
            }
        }

        written
    }

    fn seek(&self, _song: i32, _seconds: i32) {}
}
