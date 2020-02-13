""" Initializes a Rosie agent in the soar vim debugger and will display chat and action info in different panes """
import sys
import vim

from pysoarlib import SoarAgent

from VimLanguageConnector import VimLanguageConnector
from ActionStackConnector import ActionStackConnector
from VimWriter import VimWriter
from VimSoarAgent import VimSoarAgent

class VimRosieAgent(VimSoarAgent):
    def __init__(self, writer, config_filename=None, **kwargs):
        self.vim_writer = writer
        VimSoarAgent.__init__(self, writer, config_filename=config_filename, **kwargs)

        if self.messages_file != None:
            with open(self.messages_file, 'r') as f:
                lines = ( line.strip() for line in f.readlines() )
                # Filter empty lines and commented lines
                lines = ( line for line in lines if len(line) > 0 and line[0] != '#' )
                # Replace quotes with pipes
                lines = ( line.replace('"', '|') for line in lines )
                vim.command('let g:rosie_messages = ["' + '","'.join(lines) + '"]')

        self.connectors["language"] = VimLanguageConnector(self, writer)

        self.connectors["action_stack"] = ActionStackConnector(self, writer)

    def update_debugger_info(self):
        stack = self.agent.ExecuteCommandLine("p --stack", False)
        self.vim_writer.write(stack, VimWriter.SIDE_PANE_BOT, clear=True, scroll=True)

