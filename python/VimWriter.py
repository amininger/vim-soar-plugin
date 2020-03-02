import vim

class VimWriter:
    """ Used to write to different vim window panes """
    MAIN_PANE = 1
    SIDE_PANE_TOP = 2
    SIDE_PANE_MID = 3
    SIDE_PANE_BOT = 4

    window_names = { 
        MAIN_PANE: "__MAIN_PANE__",
        SIDE_PANE_TOP: "__SIDE_PANE_TOP__",
        SIDE_PANE_MID: "__SIDE_PANE_MID__",
        SIDE_PANE_BOT: "__SIDE_PANE_BOT__"
    }

    def __init__(self):
        self.win_map = {}
        for window in vim.windows:
            for win_id, win_name in VimWriter.window_names.items():
                if win_name in window.buffer.name:
                    self.win_map[win_id] = window
                    break

    def clear_all_windows(self):
        """ Deletes the contents of all debugger windows """
        for window in vim.windows:
            for name in VimWriter.window_names.values():
                if name in window.buffer.name:
                    del window.buffer[:]
                    break

    def write(self, message, window=MAIN_PANE, clear=False, scroll=True, strip=True):
        """ appends the given message onto the given window

        clear, True will delete the existing window contents before appending
        scroll, True will scroll the window to the bottom after appending
        strip, True will strip whitespace from message beginning and end
        """
        if strip:
            message = message.strip()
        window = self.win_map[window]
        if clear:
            del window.buffer[:]
        for line in message.split("\n"):
            window.buffer.append(line)
        if scroll:
            window.cursor = (len(window.buffer), 0)
        if window != VimWriter.MAIN_PANE and window in vim.windows:
            prev_win = vim.current.window
            vim.current.window = window
            vim.command("redraw!")
            vim.current.window = prev_win

    def get_window(self, window):
        """ Returns a reference to the vim window with the given identifier """
        return self.win_map[window]


