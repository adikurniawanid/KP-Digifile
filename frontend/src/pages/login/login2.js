import React from 'react'
import { Component } from 'react'
import { Add, Divfile, Divfolder, Navbar } from '../../components'
import { FaCloudUploadAlt, FaFileUpload, FaFolderPlus, FaHdd, FaServer, FaTrashAlt } from 'react-icons/fa'
import axios from 'axios'

class Coba2 extends Component {
  state = {
    Username : "rsf",
    Idxfilter : 0,
    Idxbutton :0,
    courses : null
  }

  handleChane = e => {
    this.setState({
      [e.target.name] : e.target.value
    })
  }

  componentWillMount(){
    axios.get('http://192.168.0.188:12345/get_information_storage/',{params :{
      Username : this.state.Username
      }}).then(res=> {
        console.log(res);
        this.setState({courses : res.data.data})
        console.log(this.state.courses)
        // getMydrive();
      })
      
  }

  getMydrive=()=>{
    console.log("DRIVE TERKLIK");
        if(this.state.Idxfilter === 0){
          // alert(this.state.Idxfilter)
        return(
          <div className= "md:ml-96 ml-56 mt-20 bg-red-500">
            {/* ............................................isi */}
            <Divfolder/>
            <Divfile/>
          </div>
        )
      }else if (this.state.Idxfilter === 1){
        // alert(this.state.Idxfilter)
        return(
          <div className= "md:ml-96 ml-56 mt-20 bg-red-500">
          {/* ............................................isi */}
          <Divfolder/>
        </div>
        )
      }
      else {
        // alert(this.state.Idxfilter)
        <div className= "md:ml-96 ml-56 mt-20 bg-red-500">
        {/* ............................................isi */}
        
        <Divfile/>
      </div>
      }
  }
  edit=()=>{
    return(
      <div id="list" className="container absolute bg-white rounded-lg w-1/3 h-auto m-auto -ml-96 -mt-60 pt-5 shadow">
            <h1 className = "text-2xl text-shadow-md text-black font-bold">Edit</h1>
            {/* <form className="items-center space-y-2 mt-5 ml-12 "> */}
              <div className = "flex">
                <div className = "block"> 
                  <label className="font-bold text-blue-400 -ml-8">Username</label>
                  <input className = "shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = {this.state.Username[this.state.idx-1]}
                  name="Username"
                  
                  >
                </input>
                </div>
                <div className = "block">
                  <label className="block font-bold text-blue-400 -ml-20">Nama</label>
                  <input className = "block shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = "Nama" 
                  name="Nama"
                  >
                  </input>
                </div>                    
              </div>
              <div className="flex">
                <div className = "block">
                  <label className="block font-bold text-blue-400 -ml-16">Email</label>
                  <input className = "block shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 ml-7 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = "Email"
                  name="Email"
                  
                  >
                  </input>
                </div>
                <div className = "block">
                  <label className="block font-bold text-blue-400 -ml-20">Space</label>
                  <input className = "block shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "number" placeholder = "Masukkan bilangan integer" 
                  name="Space"
                  
                  >
                  </input>
                </div>

              </div>
                <div>
                <button className ="bg-gray-200 shadow mt-5 mb-6 py-1 px-2 rounded-lg font-bold m-auto" 
                type = "submit"
                
                >Edit</button>
                </div>
            {/* </form> */}   
          </div>
    )
  
}

render(){
  return (
    <div>
      <div className="fixed z-10 w-full bg-white shadow">
          <Navbar/>
      </div>
     
      <div className="container flex bg-white py-20">
      {/* ------------------------------semua halaman */}
        <div className = "fixed h-screen bg-white px-16 pt-8 md:w-1/4 w-20">
           {/* ------------------------------------------------mulai Sidebar */}
        <div>
          {/* -----------------------------------------Tambah */}
            <Add>
                <ul id="list" className="bg-white rounded-lg p-4 w-56 mt-2 shadow absolute">
                    <li className="flex py-2"><FaFolderPlus size = {30}/><a class="dropdown-item mx-5">Folder Baru </a></li>
                    <li className="flex py-2"><FaCloudUploadAlt size = {30}/><a class="dropdown-item mx-5">Upload Folder</a></li>
                    <li className="flex py-2"><FaFileUpload size = {30}/><a class="dropdown-item mx-5">Upload File</a></li>
                </ul> 
            </Add>
            {/* --------------------------------------------Tambah */}
        </div>
          {/* ------------------------------------------------awal 3 icon */}
          
              <div>
                {/* --------------------------------------------bungkus 2 */}
          
                  <button className = "my-5 flex">
                      <FaHdd size = {30}/><a className="mx-4">My drive</a>
                  </button>
                  <button onClick={this.edit()}>=========</button>
                  <button className = "my-5 flex">
                      <FaTrashAlt size = {30}/><a className="mx-4">Trash</a>
                  </button>

                {/* --------------------------------akhir bungkus */}
              </div>
              <div className = "flex my-36">
                <FaServer size = {60}/><p className="mx-4">Penyimpanan  {this.state.courses}</p>
              </div>
          {/* ------------------------------------------akhir sidebar */}
        </div>
        <div className="fixed h-16 md:ml-96 ml-56  py-5 w-full bg-white border-b-2 border-gray-200 items items-center">
          {/* ..........................Navber kedua */}
            <select className="bg-white  w-20 h-10 text-xl items-center focus:outline-none "
            name="Idxfilter"
            value={this.state.Idxfilter}
            onChange={this.handleChane}>
              <option value={0}>All</option>
              <option value={1}>Folder</option>
              <option value={2}>File</option>
            </select>
        </div>
        {/* <this.getMydrive/> */}
        <div className="md:ml-96 ml-56 mt-96 mt-20 bg-red-500">
        <button onClick={this.getMydrive}>ganti halaman</button>
        <p>{this.state.Idxfilter}</p>
        </div>
      
      </div>
      
      
      {/* -------------------batas akhir */}
    </div>
  )
}
}

export default Coba2