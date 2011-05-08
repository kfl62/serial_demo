dojo.provide("ib.crud");
ib.crud = {
  // variables {{{1
  connections: new Array,
  buttons: new Array,
  timer: 0,
  crudOverlay: dojo.create('div',{id:"crud_overlay"}),
  crudWindow: dojo.create('div',{id:"crud_window"}),
  // get {{{2
  get: function(node){
    var path = node.href;
    path = path.split('/').slice(-3).join('/');
    xhrArgs = {
      url: '/' + path,
      load: function(data){
        ib.crud.drawBox(data);
        dojo.attr('xhr_msg','class','hidden');
        ib.crud.connect_buttons();
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    dojo.publish('xhrMsg',['loading','info']);
    var deferred = dojo.xhrGet(xhrArgs);
  },
  // edit
  edit: function(node){
    var path = node.href;
    path = path.split('/').slice(-4).join('/');
    xhrArgs = {
      url: '/' + path,
      load: function(data){
        ib.crud.drawBox(data);
        dojo.attr('xhr_msg','class','hidden');
        ib.crud.connect_buttons();
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    dojo.publish('xhrMsg',['loading','info']);
    var deferred = dojo.xhrGet(xhrArgs);
  },
  // put {{{2
  put: function(node){
    var path = node.action.split('/').slice(-4,-1).join('/');
    xhrArgs = {
      form: node,
      url:'/' + path,
      load: function(data){
        dojo.publish('xhrMsg',['flash']);
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    var deferred = dojo.xhrPut(xhrArgs);
    ib.crud.destroy();
    reload_path = node.getAttribute('data-referrer');
    ib.crud.reload(reload_path)
  },
  // delete {{{2
  delete: function(node){
    var path = node.href;
    path = path.split('/').slice(-4,-1).join('/');
    xhrArgs = {
      url: '/' + path,
      load: function(data){
        dojo.publish('xhrMsg',['flash']);
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    var deferred = dojo.xhrDelete(xhrArgs);
    ib.crud.destroy();
    reload_path = node.getAttribute('data-referrer');
    ib.crud.reload(reload_path)
  },
  // reload the content{{{2
  reload: function(path){
    xhrArgs = {
      url: path,
      load: function(data){
        dojo.byId('xhr_content').innerHTML = data;
        dojo.attr('xhr_msg','class','hidden');
        var isLoop = dojo.query('span.reload')[0];
        dojo.addClass(isLoop,'active')
        isLoop.setAttribute('title','Stop Auto-Reload')
        ib.crud.connect();
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    var deferred = dojo.xhrGet(xhrArgs);
  },
  auto_reload: function(node){
    var path = node.getAttribute('data-referrer');
    var duration = node.getAttribute('data-duration');
    if (dojo.hasClass(node,'active')){
      dojo.removeClass(node,'active')
      node.setAttribute('title','Start Auto-Reload')
      clearInterval (this.timer)
      dojo.publish('xhrMsg',['monitor.auto_reload_stop','info'])
    }else{
      dojo.addClass(node,'active')
      node.setAttribute('title','Stop Auto-Reload')
      this.timer = setInterval ("ib.crud.reload('" + path + "')",duration);
      dojo.publish('xhrMsg',['monitor.auto_reload_start','info'])
    }
  },
  // position the taskWindow{{{2
  positionBox: function(o1,o2){
    var lastX,lastY,tskww,tskwh,
    base = dojo.position(o1),
    tskw = dojo.position(o2);
    lastX = base.x + 18;
    lastY = base.y + 18;
    dojo.style(o2,{
      left:   lastX + 'px',
      top:    lastY + 'px'
    });
  },
  // draw the taskWindow{{{2
  drawBox: function(data){
    if (dojo.query('[id^="crud"]').length == 0){
      var ovl = this.crudOverlay;
      var win = this.crudWindow;
      win.innerHTML = data;
      dojo.place(ovl,dojo.body(),'first');
      dojo.place(win,ovl,'after');
      this.positionBox(dojo.byId('xhr_content'),win);
    }
    else{
      dojo.destroy(dojo.byId('crud_window'))
      var ovl = dojo.byId('crud_overlay');
      var win = this.crudWindow;
      win.innerHTML = data;
      dojo.place(win,ovl,'after');
    }
  },
  // destroy the taskWindow and reset vars{{{2
  destroy: function(){
    dojo.query('[id^="crud"]').forEach("dojo.destroy(item)");
  },
  // connect actions in list{{{2
  connect: function(){
    dojo.forEach(this.connections, dojo.disconnect);
    this.connections.length = 0;
    dojo.query('td.buttons_left > span > a').forEach(function(a){
      var verb = a.className;
      ib.crud.connections.push(
        dojo.connect(a, 'onclick', function(e){e.preventDefault();ib.crud[verb](e.target)})
      )
    })
    var isLoop = dojo.query('span.reload')[0];
    dojo.connect(isLoop,'onclick',function(e){ib.crud.auto_reload(e.target)})
  },
  //// connect buttons in crudWindow{{{2
  connect_buttons: function(){
    dojo.forEach(this.buttons, dojo.disconnect);
    this.buttons.length = 0;
    dojo.query('td.buttons_bottom > span > a').forEach(function(a){
      var verb = a.className;
      ib.crud.connections.push(
        dojo.connect(a, 'onclick', function(e){e.preventDefault();ib.crud[verb](e.target)})
      )
    })
    dojo.query('td.buttons_bottom > input').forEach(function(a){
      var verb = a.className;
      ib.crud.connections.push(
        dojo.connect(a, 'onclick', function(e){e.preventDefault();ib.crud[verb](e.target.form)})
      )
    })
  },
  not_ready: function(msg){
    alert("Coming soon - " + msg + " - !");
  }
}
// initialize on load{{{2
function init(){
  ib.crud.connect();
}
dojo.ready(init);

