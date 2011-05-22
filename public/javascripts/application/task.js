dojo.provide("ib.task");
ib.task = {
  connections: new Array,
  selectOpcode: null,
  selectOpcodeValue: "00",
  selectNode: null,
  selectNodeValue: "0",
  selectParam: null,
  taskPartial: null,
  taskSubmit: null,
  connect: function(){
    this.destroy();
    this.selectOpcode = dojo.byId('task_opcode');
    this.taskPartial = dojo.byId('xhr_partial');
    this.taskSubmit = dojo.byId('task_submit');
    if (this.selectOpcode != null){
      this.connections.push(
        dojo.connect(this.selectOpcode,"onchange",function(e){
          ib.task.selectOpcodeValue = e.target.value;
          ib.task.opcodeOnChange()
        })
      )
      dojo.connect(dojo.byId('task_submit'),'onclick',function(e){
        e.preventDefault();ib.task.sendData(e.target.form);
      })
    };
  },
  opcodeOnChange: function(){
    if (this.selectNode == null){
      this.selectNode = dojo.byId('task_node');
      dojo.removeClass(this.selectNode,'hidden')
      this.connections.push(
        dojo.connect(this.selectNode,"onchange",function(e){
          ib.task.selectNodeValue = e.target.value;
          ib.task.nodeOnChange();
        })
      )
    }else{
      if (this.selectOpcodeValue == '00'){
        this.nodeDestroy()
      }else{
        this.nodeReset(true)
      }
    }
  },
  nodeOnChange: function(){
    if (this.selectParam == null){
      path = '/ctrl/tsk/partial?opcode=' + this.selectOpcodeValue + "&node=" + this.selectNodeValue;
      xhrArgs = {
        url: path,
        load: function(data){
          ib.task.taskPartial.innerHTML = data;
          ib.task.connectParam();
        },
        error: function(error){
          dojo.publish('xhrMsg',['error','error',error]);
        }
      };
      var deferred = dojo.xhrGet(xhrArgs);
    }else{
       this.nodeReset(false)
    }
  },
  nodeDestroy: function(){
    if (this.selectParam != null){this.paramDestroy()}
    dojo.disconnect(this.connections[1])
    this.connections.length = 1
    dojo.addClass(this.selectNode,'hidden')
    this.selectNode.selectedIndex = 0
    this.selectNode = null
    this.selectNodeValue = "0"
  },
  nodeReset: function(opcode){
    if (this.selectParam != null){this.paramDestroy()}
    if (opcode || this.selectNodeValue == "0"){
      this.selectNode.selectedIndex = 0
      dojo.removeClass(this.selectNode,'hidden')
      this.selectNodeValue = "0"
    }else{
      this.nodeOnChange();
    }
  },
  connectParam: function(){
    if (this.selectParam == null){
      this.selectParam = dojo.query('.params',dojo.byId('task_form'))[0]
      this.connections.push(
        dojo.connect(this.selectParam,"onchange",function(e){
          ib.task.paramOnChange()
        })
      )
    }else{
      alert('Some error')
    }
  },
  paramOnChange: function(){
    if (this.selectParam.value == "0"){
      dojo.addClass(this.taskSubmit,'hidden')
    }else{
      dojo.removeClass(this.taskSubmit,'hidden')
    }
  },
  paramDestroy: function(){
    dojo.disconnect(this.connections[2])
    this.connections.length = 2
    this.selectParam = null
    this.taskPartial.innerHTML = ""
    if (!dojo.hasClass(this.taskSubmit,'hidden')){dojo.addClass(this.taskSubmit,'hidden')}
  },
  destroy: function(){
    dojo.forEach(this.connections, dojo.disconnect);
    this.connections.length = 0;
    this.selectOpcode = null;
    this.selectOpcodeValue = "00";
    this.selectNode = null;
    this.selectNodeValue = "0";
    this.selectParam = null;
    this.taskPartial = null;
    this.taskSubmit = null;
  },
  sendData: function(node){
    var info_node = dojo.byId('last_log');
    var anim = dojo.animateProperty({
        node: info_node,
        duration: 5000,
        properties:{
          opacity: {end: 1, start: 1}
        },
        onEnd: function(){
          dojo.attr(info_node,'class','hidden');
        }
      });
    var path = '/ctrl/tsk/execute'
    xhrArgs = {
      form: node,
      url: path,
      load: function(data){
        info_node.innerHTML = data;
        dojo.attr(info_node,'class','info');
        dojo.style(info_node,{'opacity': 1});
        anim.play();
      },
      error: function(error){
        dojo.publish('xhrMsg',['error','error',error]);
      }
    };
    var deferred = dojo.xhrPost(xhrArgs);
  }
}