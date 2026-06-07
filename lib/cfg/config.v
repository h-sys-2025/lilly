// Copyright 2026 The Lilly Edtior contributors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

module cfg

import os
import kdlv
import lib.petal.theme

pub const light_theme_name = theme.light_theme_name
pub const dark_theme_name = theme.dark_theme_name

pub struct Config {
pub:
	theme       theme.Theme
	leader_key  string
	expand_tabs bool
	tab_width   int
}

pub struct ConfigFile {
pub mut:
	theme       string
	leader_key  string
	expand_tabs bool
	tab_width   int
}

@[params]
pub struct ConfigOptions {
pub:
	// TODO(valxntine) [06/04/2026]: keeping this for now until we discuss potential --config CLI flags
	// also keeping this in Config.new to allow the provided path to take precendence over everything
	load_from_path ?string
}

fn xdg_config_paths() []string {
	mut paths := []string{}

	cfg_home := os.getenv('XDG_CONFIG_HOME')
	if cfg_home.len > 0 && os.is_abs_path(cfg_home) {
		paths << os.join_path(cfg_home, 'lilly', 'lilly.cfg')
	} else {
		paths << os.join_path(os.home_dir(), '.config', 'lilly', 'lilly.cfg')
	}

	cfg_dirs := os.getenv('XDG_CONFIG_DIRS')
	dirs := if cfg_dirs.len > 0 { cfg_dirs.split(':') } else { ['/etc/xdg'] }
	for dir in dirs {
		if os.is_abs_path(dir) {
			paths << os.join_path(dir, 'lilly', 'lilly.cfg')
		}
	}

	return paths
}

pub fn parse_config_file(file_path string) !Config {
	mut ttheme := theme.dark_theme
	mut leader_key := ';'
	mut expand_tabs := false
	mut tab_width := 4

	$if !windows {
		file := os.read_file(os.expand_tilde_to_home(file_path))!

		doc := kdlv.parse(file)!
		if doc.nodes.len == 0 {
			return error('empty config file')
		}

		if doc.nodes[0].name != 'config' {
			return error('no config node')
		}

		mut config := kdlv.decode[ConfigFile](kdlv.generate(kdlv.Document{
			nodes: doc.nodes[0].children
		}, kdlv.GenerateOptions{}))!

		config.theme = config.theme.trim_space()

		match config.theme {
			'light' { ttheme = theme.light_theme }
			'dark' { ttheme = theme.dark_theme }
			'' {}
			else { return error('unknown theme') }
		}

		if config.leader_key != '' {
			if config.leader_key.len != 1 {
				return error('invalid leader key, too long')
			}
			leader_key = config.leader_key
		}

		expand_tabs = config.expand_tabs

		if config.tab_width > 0 {
			tab_width = config.tab_width
		}
	}

	return Config{
		theme:       ttheme
		leader_key:  leader_key
		expand_tabs: expand_tabs
		tab_width:   tab_width
	}
}

pub fn Config.new(opts ConfigOptions) Config {
	if path_to_load := opts.load_from_path {
		if parsed_config := parse_config_file(path_to_load) {
			return parsed_config
		}
	}

	for path in xdg_config_paths() {
		if parsed_config := parse_config_file(path) {
			return parsed_config
		}
	}

	return Config{
		theme:      theme.dark_theme
		leader_key: ';'
		tab_width:  4
	}
}

pub fn (c Config) set_theme(name string) Config {
	return Config{
		...c
		theme: if name == 'dark' { theme.dark_theme } else { theme.light_theme }
	}
}
