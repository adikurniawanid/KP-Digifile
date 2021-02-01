import React from 'react';
import {defaultStyles, FileIcon} from 'react-file-icon';
import { Component } from 'react';
import axios from 'axios'
import './file.css'
import Fileviewer from 'react-file-viewer'
import { FaFolder } from 'react-icons/fa';

const curren_path = []
class Fileview extends Component{
  state = {
    hasil : "",
    inputan : null
  }

  handleChane = e => {
    this.setState({
      [e.target.name] : e.target.value
    })
  
  }

  hapus=()=>{
    curren_path.pop(this.state.inputan)
    this.hasil()
    console.log("/"+this.state.hasil)
  }
  push=()=>{
    //console.log(this.state.inputan)
    curren_path.push(this.state.inputan)
    this.hasil()
    console.log("/"+this.state.hasil)
  }
  hasil=()=>{
    this.state.hasil = curren_path.join('/')
  }

render(){
  return (
    <div className= "z-0 md:ml-96 ml-56 mt-20 h-screen">
      <div>
      <button type="text" name="inputan" value="folder a" onMouseEnter={this.handleChane} onClick={this.push}>INI FOLDER A</button>

      </div>
      <div>
      <button type="text" name="inputan" value="folder b" onMouseEnter={this.handleChane} onClick={this.push}>INI FOLDER B</button>
        
      </div>
      <div>
      <button type="text" name="inputan" value="folder c" onMouseEnter={this.handleChane} onClick={this.push}>INI FOLDER C</button>
        
      </div>

      <button onClick={this.hapus}>hapus</button>
      <p>==================</p>
      {/* <button onClick={this.push}>Input</button> */}
    </div>
   
  );
}
}

export default Fileview;
