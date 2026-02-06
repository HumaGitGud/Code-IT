import {
  JupyterFrontEnd,
  JupyterFrontEndPlugin
} from '@jupyterlab/application';

import { requestAPI } from './request';

import {ICommandPalette} from '@jupyterlab/apputils'
import { Widget } from '@lumino/widgets';
import { MainAreaWidget } from '@jupyterlab/apputils';

/**
 * Initialization data for the code-it extension.
 */
const plugin: JupyterFrontEndPlugin<void> = {
  id: 'code-it:plugin',
  description: 'An extension for The Littlest JupyterHub to facilitate RTC peer-programming.',
  autoStart: true,
  requires: [ ICommandPalette ],
  activate: (app: JupyterFrontEnd,
             palette: ICommandPalette ) => {
    console.log('JupyterLab extension code-it is activated!');

    let commandId = 'code-it:Hello';
    app.commands.addCommand(commandId,
    { 
        label: 'Hello World',
        execute: () => { say_hello(app) }
    });

    palette.addItem(
        { command: commandId,
          category: 'Anything'
        });

    function say_hello(app: JupyterFrontEnd) {
        let content = new HelloWorldWidget();
        let widget = new MainAreaWidget({content});

        app.shell.add(widget, 'main');
        app.shell.activateById(widget.id);
    }

    class HelloWorldWidget extends Widget {
        constructor() {
            super();
            this.id = 'hello-world';
            this.title.label = 'Hello World';
            this.title.closable = true;
            this.addClass('hww');
            let body = document.createElement('body');
            let heading = document.createElement('h1');
            heading.innerText = 'Hello World from GRC!';
            body.appendChild(heading);
            this.node.appendChild(body);
        }
    }
                 
    requestAPI<any>('hello')
      .then(data => {
        console.log(data);
      })
      .catch(reason => {
        console.error(
          `The code_it server extension appears to be missing.\n${reason}`
        );
      });
  }




};

export default plugin;
