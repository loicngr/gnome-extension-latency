import Gio from 'gi://Gio';
import Adw from 'gi://Adw';
import Gtk from 'gi://Gtk';

import {ExtensionPreferences, gettext as _} from 'resource:///org/gnome/Shell/Extensions/js/extensions/prefs.js';

export default class LatencyPreferences extends ExtensionPreferences {
    fillPreferencesWindow(window) {
        // Create a preferences page, with a single group
        const page = new Adw.PreferencesPage({
            title: _('General'),
            icon_name: 'dialog-information-symbolic',
        });
        window.add(page);

        const group = new Adw.PreferencesGroup({
            title: _('Display Options'),
            description: _('Configure how latency information is displayed'),
        });
        page.add(group);

        // Create a new preferences row
        const row = new Adw.SwitchRow({
            title: _('Show "Latency" Label'),
            subtitle: _('Display the word "Latency:" before the ping value'),
        });
        group.add(row);

        // Create a settings object
        window._settings = this.getSettings();

        // Bind the switch to our `show-latency-label` key
        window._settings.bind(
            'show-latency-label',
            row,
            'active',
            Gio.SettingsBindFlags.DEFAULT
        );
    }
}
