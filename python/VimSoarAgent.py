""" Creates a soar agent to use in the vim debugger and displays common state info """
import sys

from pysoarlib import SoarAgent

from VimWriter import VimWriter

class VimSoarAgent(SoarAgent):
    def __init__(self, writer, config_filename=None, **kwargs):
        self.vim_writer = writer
        SoarAgent.__init__(self, config_filename=config_filename, 
                print_handler = lambda message: writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True),
                spawn_debugger=False, write_to_stdout=False, **kwargs)

    def update_debugger_info(self):
        cur_state = self.agent.ExecuteCommandLine("p <s>", False)
        self.vim_writer.write(cur_state, VimWriter.SIDE_PANE_TOP, clear=True, scroll=False)
        prefs = self.agent.ExecuteCommandLine("preferences <s> operator --names", False)
        self.vim_writer.write(prefs, VimWriter.SIDE_PANE_MID, clear=True, scroll=False)
        stack = self.agent.ExecuteCommandLine("p --stack", False)
        self.vim_writer.write(stack, VimWriter.SIDE_PANE_BOT, clear=True, scroll=False)


