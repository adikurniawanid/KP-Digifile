import React from 'react';
import {defaultStyles, FileIcon} from 'react-file-icon';
import { Component } from 'react';
// import axios from 'axios'
import './file.css'
import { FaFolder, FaTrash } from 'react-icons/fa';
import { Editiitems } from '../../components';


class Edit extends Component{
  state = {
    Idedit : null,
  }

  handleChane = e => {
    this.setState({
      [e.target.name] : e.target.value
    })
  }


render(){

  return (
    <div className= "z-0 md:ml-96 ml-56 mt-20 h-screen space-y-40">
      <button name="Idedit" value={134} onMouseEnter={this.handleChane}>
            <button>
            <div className="block absolute ml-32 -mt-40 -space-y-2">
              <div>
               <button><FaTrash size={12}/></button>
              </div>
              <div>
               <button><FaTrash size={12}/></button>
              </div>
            </div>
            </button>
          <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
          >
          <img className="w-full h-32 object-cover rounded-xl " src="" alt="">
          </img>
          <p className="wrapword">lalalalal</p>
        </button> 
        </button>
        {this.state.Idedit}
    </div>
  )
}
}

export default Edit;
