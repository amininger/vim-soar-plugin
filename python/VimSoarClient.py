""" Creates a soar client to use in the vim debugger and displays common state info """
import sys

from pysoarlib import SoarClient

from VimWriter import VimWriter
from VimConnector import VimConnector

class VimSoarClient(SoarClient):
    def __init__(self, writer, config_filename=None, **kwargs):
        self.vim_writer = writer
        SoarClient.__init__(self, config_filename=config_filename, 
                print_handler = lambda message: writer.write(message, VimWriter.MAIN_PANE, clear=False, scroll=True),
                spawn_debugger=False, write_to_stdout=True, **kwargs)

        self.vim_connector = VimConnector(self, writer)
        self.add_connector("vim", self.vim_connector)

    def execute_command(self, cmd, print_res=False):
        if self.has_connector('vim'):
            self.vim_connector.record_command(cmd)
        super().execute_command(cmd, print_res)

    def update_debugger_info(self):
        cur_state = self.agent.ExecuteCommandLine("p <s>", False)
        self.vim_writer.write(cur_state, VimWriter.SIDE_PANE_TOP, clear=True, scroll=False)
        prefs = self.agent.ExecuteCommandLine("preferences <s> operator --names", False)
        self.vim_writer.write(prefs, VimWriter.SIDE_PANE_MID, clear=True, scroll=False)
        stack = self.agent.ExecuteCommandLine("p --stack", False)
        self.vim_writer.write(stack, VimWriter.SIDE_PANE_BOT, clear=True, scroll=True)

