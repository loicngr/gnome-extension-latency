/* extension.js
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * SPDX-License-Identifier: GPL-2.0-or-later
 */

import GObject from "gi://GObject";
import GLib from "gi://GLib";
import Gio from "gi://Gio";
import Clutter from "gi://Clutter";
import St from "gi://St";

import * as Main from "resource:///org/gnome/shell/ui/main.js";
import * as PanelMenu from "resource:///org/gnome/shell/ui/panelMenu.js";
import {Extension} from "resource:///org/gnome/shell/extensions/extension.js";

const refreshInterval = 5;

const Indicator = GObject.registerClass(
  class Indicator extends PanelMenu.Button {
    _init() {
      // `menuAlignment`, `nameText`, `dontCreateMenu`.
      super._init(0.0, "Latency", true);

      this._label = new St.Label({
        "y_align": Clutter.ActorAlign.CENTER,
        "text": ""
      });

      this.add_child(this._label);
    }

    setText(text) {
      return this._label.set_text(text);
    }
  });

export default class Latency extends Extension {
  constructor(metadata) {
    super(metadata);

    this._metadata = metadata;
    this._uuid = metadata.uuid;
  }

  enable() {
    this._textDecoder = new TextDecoder();
    this._timeout = null;

    this._indicator = new Indicator();
    // `role`, `indicator`, `position`, `box`.
    // `-1` is not OK for position, it will show at the right of system menu.
    Main.panel.addToStatusArea(this._uuid, this._indicator, 0, "right");

    this._timeout = GLib.timeout_add_seconds(
      GLib.PRIORITY_DEFAULT, refreshInterval, () => {
        const latency = this.getCurrentLatency(refreshInterval);
        // console.log(latency);
        this._indicator.setText(latency);
        // Run as loop, not once.
        return GLib.SOURCE_CONTINUE;
      }
    );
  }

  disable() {
    if (this._indicator != null) {
      this._indicator.destroy();
      this._indicator = null;
    }
    this._textDecoder = null;
    this._lastSum = null;
    if (this._timeout != null) {
      GLib.source_remove(this._timeout);
      this._timeout = null;
    }
  }

  getCurrentLatency(refreshInterval) {
    let status = '';
    let stderr = '';
    let stdout = '';

    try {
        const proc = Gio.Subprocess.new(['./.local/share/gnome-shell/extensions/latency/show-ping-time.sh'],
            Gio.SubprocessFlags.STDOUT_PIPE | Gio.SubprocessFlags.STDERR_PIPE);

        const [status, stdout, stderr] = proc.communicate_utf8(null, null);

        if (proc.get_successful())
            // console.log(stdout);
            return stdout;
        else
            throw new Error(stderr);
    } catch (e) {
        logError(e);
    }
  }
};
