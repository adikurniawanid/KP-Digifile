import React from 'react';
import { Add } from '../../atom';
import { FaTrashAlt, FaServer, FaHdd } from "react-icons/fa"
import { FaFolderPlus, FaFileUpload, FaCloudUploadAlt } from "react-icons/fa";
import { Component } from 'react';
import axios from 'axios';


class Sidebar extends Component{
    state ={
        Username : "rsf",
        courses : null
    }
    componentWillMount(){
        axios.get('http://192.168.0.188:12345/get_information_storage/',{params :{
          Username : this.state.Username
          }}).then(res=> {
            console.log(res);
            this.setState({courses : res.data.data})
            console.log(this.state.courses)
          })
      }
      
// const Sidebar = () => {
render(){
    return(    
        <div className = "fixed h-screen bg-white px-16 pt-8 md:w-1/4 w-20">
            <div className ="">
                <Add>
                    <ul id="list" className="bg-white rounded-lg p-4 w-56 mt-2 shadow absolute">
                        <li className="flex py-2"><FaFolderPlus size = {30}/><a href="#" class="dropdown-item mx-5" href="">Folder Baru </a></li>
                        <li className="flex py-2"><FaCloudUploadAlt size = {30}/><a href="#" class="dropdown-item mx-5" href="">Upload Folder</a></li>
                        <li className="flex py-2"><FaFileUpload size = {30}/><a href="#" class="dropdown-item mx-5" href="">Upload File</a></li>
                    </ul> 
                </Add>
            </div>
            <div>
                <div className = "my-5 flex">
                <FaHdd size = {30}/><a className="mx-4" href ="#">My drive</a>
                </div>
                <div className = "my-5 flex">
                    <FaTrashAlt size = {30}/><a className="mx-4" href ="#">Trash</a>
                </div>
                <div className = "flex my-36">
                    <FaServer size = {60}/><p className="mx-4">Penyimpanan {this.state.courses}</p>
                    
                </div>
            </div>
        </div>
    )
}
}

export default Sidebar