import React from 'react'
import { TabGroup } from '@statikly/funk'
import { Component } from 'react'
import { Add, Divfile, Divfolder, Editiitems, File, Navbar } from '../../components'
import { FaFolder, FaHdd, FaServer, FaTrashAlt, FaArrowAltCircleLeft, FaSearch, FaTrash, FaRecycle, FaEdit, FaDownload } from 'react-icons/fa'
import axios from 'axios'
import Uploadfolder from '../../components/atom/upload/uploadfolder'
import Uploadfile from '../../components/atom/upload/uploadfile'
import Addfolder from '../../components/atom/upload/addfolder'
import Upfile from '../../components/atom/upload/uploadingfile'
import {defaultStyles, FileIcon} from 'react-file-icon';
import Createfolder from '../../components/atom/upload/createfolder'
import Upfolder from '../../components/atom/upload/uploadingfolder'
import Rename from '../../components/atom/upload/buttonrename'

const Temp = []
class Coba extends Component {
  state = {
    Username : sessionStorage.getItem("Usernameuser"),
    Idxfilter : 0,
    courses : null,

    Extention : [],
    Panjang: null,
    Namefile : [],
    Curren_path : "",
    Namefolder : null,
// ------------------------------ini trash
    // Namefolder: [],
    Isisemua: [],
    Isifolder :[],
    Isifile :[],
    Idfile : [],
    idfolder : [],
    Idisisemua : [],
// -------------------------------------ini my drive
    Isisemuad: [],
    Isifolderd :[],
    Isifiled :[],
    Idfiled : [],
    idfolderd : [],
    Idisisemuad : [],
    Panjangd :null,
    Extentiond: [],

    // -----------------------------------------search
    Key : null,
    Folder : [],
    Isisemuas :[],
    Panjangs : null,
    Extensis : [],
    Ids : [],

    // ---------------------------------edit
    Idedit : null,
    Rename : null,
  }
  handleChane = e => {
    this.setState({
      [e.target.name] : e.target.value
    })
    console.log(this.state.Idedit)
  }


  search=()=>{
    console.log("masuk Klik")
    axios.get('http://192.168.0.188:12345/search_user/',{params :{
        Username : sessionStorage.getItem("Usernameuser"),
        Item_name : this.state.Key
        }}).then(res=>{
          this.setState({Isisemuas : res.data.data})
          this.setState({Panjangs : res.data.file})
          this.setState({Extensis : res.data.ekstensi})
          this.setState({Ids : res.data.id})
          console.log(res)
        },(err)=>{
            console.log("gagal untuk search")
        }
        )
  }

  hapus=()=>{
    Temp.pop(this.state.Namefolder)
    this.hasil()
    console.log("/"+this.state.Curren_path)
    sessionStorage.setItem("Current", this.state.Curren_path)
    if (this.state.Idxfilter==0) {
      axios.get('http://192.168.0.188:12345/get_all_item_list/?',{params :{
        Username : sessionStorage.getItem("Usernameuser"),
        Curent_path : this.state.Curren_path
    }}
      ).then(res => {
        this.setState({
          Isisemuad : res.data.data,
          Panjangd : res.data.file,
          Extentiond : res.data.ekstensi,
          Idisisemuad : res.data.id
        })

        console.log(res)

    }).catch(error => {
        console.log(error)
    })
    }
    else if(this.state.Idxfilter==1){
      axios.get('http://192.168.0.188:12345/get_folder_list/?',{params :{
        Username : sessionStorage.getItem("Usernameuser"),
        Curent_path : this.state.Curren_path
      }}
        ).then(res => {
          this.setState({
            Isifolderd : res.data.data,
            Idfolderd : res.data.id,
          })
          console.log(res)

      }).catch(error => {
          console.log(error)
    })
    console.log("folder")}
  }
  push=()=>{
    //console.log(this.state.inputan)
    Temp.push(this.state.Namefolder)
    this.hasil()
    console.log("/"+this.state.Curren_path)
    sessionStorage.setItem("Current", this.state.Curren_path)
     if (this.state.Idxfilter==0) {
      axios.get('http://192.168.0.188:12345/get_all_item_list/?',{params :{
      Username : sessionStorage.getItem("Usernameuser"),
      Curent_path : this.state.Curren_path
    }}
      ).then(res => {
        this.setState({
          Isisemuad : res.data.data,
          Panjangd : res.data.file,
          Extentiond : res.data.ekstensi,
          Idisisemuad : res.data.id
        })

        console.log(res)

    }).catch(error => {
        console.log(error)
    })
    }
    else if(this.state.Idxfilter==1){
      axios.get('http://192.168.0.188:12345/get_folder_list/?',{params :{
        Username : sessionStorage.getItem("Usernameuser"),
        Curent_path : this.state.Curren_path
      }}
        ).then(res => {
          this.setState({
            Isifolderd : res.data.data,
            Idfolderd : res.data.id,
          })
          console.log(res)

      }).catch(error => {
          console.log(error)
    })
    console.log("folder")
  }}

  hasil=()=>{
    this.state.Curren_path = Temp.join('/')
  }

  delete=()=>{
    console.log("ini recovery",this.state.Idedit)
    axios.delete('http://192.168.0.188:12345/delete_file/?',{data :{
      File_id : this.state.Idedit,
      Username : sessionStorage.getItem("Usernameuser")
    }}).then(res => {
        console.log(res)
    }).catch(error => {
        console.log(error)
    })
    console.log("ini delete "+this.state.editfield)
  }
  deletefolder=()=>{
    console.log("ini recovery",this.state.Idedit)
    axios.delete('http://192.168.0.188:12345/delete_folder/?',{data :{
      Folder_id : this.state.Idedit,
      Username : sessionStorage.getItem("Usernameuser")
    }}).then(res => {
        console.log(res)
    }).catch(error => {
        console.log(error)
    })
  }

  async rename(){
    // console.log("ini rename",this.state.Idedit)
    const params = new URLSearchParams()
    params.append('Id', this.state.Idedit)
    params.append('New_name', this.state.Rename)
    params.append('Username', sessionStorage.getItem("Usernameuser"))
    await axios.put('http://192.168.0.188:12345/rename_file/',params)
    this.replace()
  }
  deletetrash=()=>{
    axios.delete('http://192.168.0.188:12345/delete_trash_file/?',{data :{
      File_id : this.state.Idedit,
      Owner : sessionStorage.getItem("Usernameuser")
    }}).then(res => {
        console.log(res)
    }).catch(error => {
        console.log(error)
    })
    console.log("ini delete trash",this.state.Idedit)
  }
  recovery=()=>{
    // console.log("ini recovery",this.state.Idedit)
    const params = new URLSearchParams()
    params.append('File_id', this.state.Idedit)
    params.append('Username', sessionStorage.getItem("Usernameuser"))
    axios.put('http://192.168.0.188:12345/recovery_trash_file/',params)
      .then(res =>{
        this.setState({courses : res.data.data})
        console.log(res)
      })
  }
  recoveryfolder=()=>{
    console.log("ini recovery",this.state.Idedit)
    const params = new URLSearchParams()
    params.append('Folder_id', this.state.Idedit)
    params.append('Username', sessionStorage.getItem("Usernameuser"))
    axios.put('http://192.168.0.188:12345/recovery_trash_folder/',params)
      .then(res =>{
        this.setState({courses : res.data.data})
        console.log(res)
      })
  }
  deletetrashfolder=()=>{
    axios.delete('http://192.168.0.188:12345/delete_trash_folder/?',{data :{
      File_id : this.state.Idedit,
      Owner : sessionStorage.getItem("Usernameuser")
    }}).then(res => {
        console.log(res)
    }).catch(error => {
        console.log(error)
    })
    console.log("ini delete trash",this.state.Idedit)
  }

  replace(){
    window.location.reload()
  }
// .................---------------------------------------------------------------ini dikmount TRASH
  componentWillMount(){
    axios.get('http://192.168.0.188:12345/get_information_storage/',{params :{
      Username : this.state.Username
      }}).then(res=> {
        this.setState({courses : res.data.data})
      })
      if (this.state.Idxfilter==0) {
        axios.get('http://192.168.0.188:12345/get_all_item_list/?',{params :{
        Username : sessionStorage.getItem("Usernameuser"),
          Curent_path : this.state.Curren_path
      }}
        ).then(res => {
          this.setState({
            Isisemuad : res.data.data,
            Panjangd : res.data.file,
            Extentiond : res.data.ekstensi,
            Idisisemuad : res.data.id
          })
      }).catch(error => {
          console.log(error)
      })}    
      sessionStorage.setItem("Current", "")
  }
  filter=()=>{
    sessionStorage.getItem("Current", "")
    console.log(this.state.Idxfilter)
      if (this.state.Idxfilter==0) {
        axios.get('http://192.168.0.188:12345/get_all_trash_list/?',{params :{
        Username : sessionStorage.getItem("Usernameuser")
      }}
        ).then(res => {
          this.setState({
            Isisemua : res.data.data,
            Panjang : res.data.file,
            Extention : res.data.ekstensi,
            Idisisemua : res.data.id
          })
          console.log(this.state.Idisisemua)
      }).catch(error => {
          console.log(error)
      })
      }
  }
// -----------------------------------------------------------------------------------------------------------------ini akhir trash
// -----------------------------------------------------------------------------------------MY Drive
filterd=()=>{
  console.log(this.state.Idxfilter)
    if (this.state.Idxfilter==0) {
      axios.get('http://192.168.0.188:12345/get_all_item_list/?',{params :{
      Username : sessionStorage.getItem("Usernameuser"),
      Curent_path : this.state.Curren_path
    }}
      ).then(res => {
        this.setState({
          Isisemuad : res.data.data,
          Panjangd : res.data.file,
          Extentiond : res.data.ekstensi,
          Idisisemuad : res.data.id
        })

        console.log(res)

    }).catch(error => {
        console.log(error)
    })
    }
    else if(this.state.Idxfilter==1){
      axios.get('http://192.168.0.188:12345/get_folder_list/?',{params :{
        Username : sessionStorage.getItem("Usernameuser"),
        Curent_path : this.state.Curren_path
      }}
        ).then(res => {
          this.setState({
            Isifolderd : res.data.data,
            Idfolderd : res.data.id,
          })
          console.log(res)

      }).catch(error => {
          console.log(error)
    })
    console.log("folder")}
    else if(this.state.Idxfilter==2){
      axios.get('http://192.168.0.188:12345/get_file_list/?',{params :{
      Username : sessionStorage.getItem("Usernameuser"),
      Curent_path : this.state.Curren_path
    }}
      ).then(res => {
        this.setState({
          Isifiled : res.data.data,
          Extentiond : res.data.ekstensi,
          Idfiled : res.data.id
        })
        this.setState({})
        console.log("file")
        console.log(res)

         
    }).catch(error => {
        console.log(error)
    })
    } 
}
// ----------------------------------------------------------------------------------akhir my Drive
render(){

  if(sessionStorage.getItem("Usernameuser")===null){
    this.props.history.push("/")
  }
  let i = 0;
// ............................------------------------------------------------------------------------------------ini TRashhhhh
  const semua = []
    if (this.state.Isisemua != null) {
      for (let i = this.state.Panjang; i < this.state.Isisemua.length; i++) {
        semua.push(
          <>
          <button name="Idedit" onMouseEnter={this.handleChane} value={this.state.Idisisemua[i]} className="flex items-center px-2 space-x-2 bg-gray-200 w-40 h-10 rounded-lg m-2 focus:outline-none" type = "submit">
            <FaFolder size={20}/><p>{this.state.Isisemua[i]}</p>
            <div className="absolute pl-28 -space-y-2">
              <div>
               <button onClick={this.recoveryfolder}><FaRecycle size={12}/></button>
              </div>
              <div>
               <button onClick={this.deletetrashfolder}><FaTrash size={12}/></button>
              </div>
            </div>
          </button>
        </>
        )
        
      }
    }
    
    for (let i = 0; i < this.state.Panjang ; i++) {
        if (this.state.Extention[i]=== "mp4") {
            semua.push(
              <button name="Idedit" value={this.state.Idisisemua[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                  <div>
                  <button className="-ml-8 mt-10 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.recovery}><FaRecycle size={12}/></button>
                  </div>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.deletetrash}><FaTrash size={12}/></button>
                  </div>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extention[i]}{...defaultStyles.mp4}/>
              <p className="wrapword">{this.state.Isisemua[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extention[i]==="pdf") {
            semua.push(
              <button name="Idedit" value={this.state.Idisisemua[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                  <div>
                  <button className="-ml-8 mt-10 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.recovery}><FaRecycle size={12}/></button>
                  </div>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.deletetrash}><FaTrash size={12}/></button>
                  </div>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extention[i]}{...defaultStyles.pdf}/>
              <p className="wrapword">{this.state.Isisemua[i]}</p>
            </button> 
            </button>
           )
          }
          else if (this.state.Extention[i]==="jpg") {
            const src = "http://192.168.0.188:12345/download_file/?Username="+sessionStorage.getItem("Usernameuser")+"&Current_path=/&File_name="+this.state.Isisemua[i]
            semua.push(
              <button name="Idedit" value={this.state.Idisisemua[i]} onMouseEnter={this.handleChane} >

                <div>
                  <div className="block absolute ml-32 space-y-1">
                    <div>
                    <button className="-ml-8 mt-10 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.recovery}><FaRecycle size={12}/></button>
                    </div>
                    <div>
                    <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.deletetrash}><FaTrash size={12}/></button>
                    </div>
                  </div>
                  </div>
                <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
                >
                <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
                </img>
                <p className="wrapword">{this.state.Isisemua[i]}</p>
              </button> 
              </button>
            )
          }
          else if (this.state.Extention[i]==="png") {
            const src = "http://192.168.0.188:12345/download_file/?Username="+sessionStorage.getItem("Usernameuser")+"&Current_path=/&File_name="+this.state.Isisemua[i]
            semua.push(
              <button name="Idedit" value={this.state.Idisisemua[i]} onMouseEnter={this.handleChane} >
                {console.log("ini png ======= ",this.state.Idisisemua[i])}
                <div>
                  <div className="block absolute ml-32 space-y-1">
                    <div>
                    <button className="-ml-8 mt-10 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.recovery}><FaRecycle size={12}/></button>
                    </div>
                    <div>
                    <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.deletetrash}><FaTrash size={12}/></button>
                    </div>
                  </div>
                  </div>
                <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
                >
                <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
                </img>
                <p className="wrapword">{this.state.Isisemua[i]}</p>
              </button> 
              </button>
            )
          }
          else if (this.state.Extention[i]==="jpeg") {
            const src = "http://192.168.0.188:12345/download_file/?Username="+sessionStorage.getItem("Usernameuser")+"&Current_path=/&File_name="+this.state.Isisemua[i]
            semua.push(
              <button name="Idedit" value={this.state.Idisisemua[i]} onMouseEnter={this.handleChane} >

                <div>
                  <div className="block absolute ml-32 space-y-1">
                    <div>
                    <button className="-ml-8 mt-10 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.recovery}><FaRecycle size={12}/></button>
                    </div>
                    <div>
                    <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.deletetrash}><FaTrash size={12}/></button>
                    </div>
                  </div>
                  </div>
                <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
                >
                <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
                </img>
                <p className="wrapword">{this.state.Isisemua[i]}</p>
              </button> 
              </button>
            )
          }
          else if (this.state.Extention[i]==="gif") {
            const src = "http://192.168.0.188:12345/download_file/?Username="+sessionStorage.getItem("Usernameuser")+"&Current_path=/&File_name="+this.state.Isisemua[i]
            semua.push(
              <button name="Idedit" value={this.state.Idisisemua[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                  <div>
                  <button className="-ml-8 mt-10 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.recovery}><FaRecycle size={12}/></button>
                  </div>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.deletetrash}><FaTrash size={12}/></button>
                  </div>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
              </img>
              <p className="wrapword">{this.state.Isisemua[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extention[i]==="docx") {
            semua.push(
              <button name="Idedit" value={this.state.Idisisemua[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                  <div>
                  <button className="-ml-8 mt-10 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.recovery}><FaRecycle size={12}/></button>
                  </div>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.deletetrash}><FaTrash size={12}/></button>
                  </div>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extention[i]}{...defaultStyles.docx}/>
              <p className="wrapword">{this.state.Isisemua[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extention[i]==="obb") {
            semua.push(
              <button name="Idedit" value={this.state.Idisisemua[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                  <div>
                  <button className="-ml-8 mt-10 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.recovery}><FaRecycle size={12}/></button>
                  </div>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.deletetrash}><FaTrash size={12}/></button>
                  </div>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extention[i]}{...defaultStyles.obj}/>
              <p className="wrapword">{this.state.Isisemua[i]}</p>
            </button> 
            </button>
            )
          }
          else {
            semua.push(
              <button name="Idedit" value={this.state.Idisisemua[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                  <div>
                  <button className="-ml-8 mt-10 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.recovery}><FaRecycle size={12}/></button>
                  </div>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.deletetrash}><FaTrash size={12}/></button>
                  </div>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extention[i]}/>
              <p className="wrapword">{this.state.Isisemua[i]}</p>
            </button> 
            </button>
            )
          }
      
    }
    // ----------------------------------------------------------------------------------ini akhir trash

    //-----------------------------------------------------------------------------ini awal my drive
    const itemsd = []
  if (this.state.Isifiled != null) {
    for (let i = 0; i < this.state.Isifiled.length ; i++) {
    const src = "http://192.168.0.188:12345/download_file/?Username="+sessionStorage.getItem("Usernameuser")+"&Current_path=/"+this.state.Curren_path+"&File_name="+this.state.Isisemuad[i]
      if (this.state.Extentiond[i]=== "mp4") {
        itemsd.push(
          <button name="Idedit" value={this.state.Idfiled[i]} onMouseEnter={this.handleChane} >
          <div>
            <div className="block absolute ml-32 space-y-1">
              <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
              <div>
              <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
              </div>
              <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                  </a>
            </div>
            </div>
          <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
          >
          <FileIcon extension={this.state.Extentiond[i]}{...defaultStyles.mp4}/>
          <p className="wrapword">{this.state.Isifiled[i]}</p>
        </button> 
        </button>
        )
      }
      else if (this.state.Extentiond[i]==="pdf") {
        itemsd.push(
          <button name="Idedit" value={this.state.Idfiled[i]} onMouseEnter={this.handleChane}>
          <div>
            <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
              <div>
              <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
              </div>
              <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                  </a>
            </div>
            </div>
          <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
          >
          <FileIcon extension={this.state.Extentiond[i]}{...defaultStyles.pdf}/>
          <p className="wrapword">{this.state.Isifiled[i]}</p>
        </button> 
        </button>
        )
      }
      else if (this.state.Extentiond[i]==="jpg") {
        itemsd.push(
          <button name="Idedit" value={this.state.Idfiled[i]} onMouseEnter={this.handleChane} >
      
                <div>
                  <div className="block absolute ml-32 space-y-1">
                  <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                    <div>
                    <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                    </div>
                    <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                  </a>
                  </div>
                  </div>
                <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
                >
                <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
                </img>
                <p className="wrapword">{this.state.Isifiled[i]}</p>
              </button> 
              </button>
        )
      }
      else if (this.state.Extentiond[i]==="png") {
        itemsd.push(
          <button name="Idedit" value={this.state.Idfiled[i]} onMouseEnter={this.handleChane} >

          <div>
            <div className="block absolute ml-32 space-y-1">
                  <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
              <div>
              <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
              </div>
              <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                  </a>
            </div>
            </div>
          <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
          >
          <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
          </img>
          <p className="wrapword">{this.state.Isifiled[i]}</p>
        </button> 
        </button>
        )
      }
      else if (this.state.Extentiond[i]==="jpeg") {
        itemsd.push(
          <button name="Idedit" value={this.state.Idfiled[i]} onMouseEnter={this.handleChane} >

          <div>
            <div className="block absolute ml-32 space-y-1">
                  <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
              <div>
              <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
              </div>
              <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                  </a>
            </div>
            </div>
          <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
          >
          <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
          </img>
          <p className="wrapword">{this.state.Isifiled[i]}</p>
        </button> 
        </button>
        )
      }
      else if (this.state.Extentiond[i]==="gif") {        
        itemsd.push(
          <button name="Idedit" value={this.state.Idfiled[i]} onMouseEnter={this.handleChane} >

          <div>
            <div className="block absolute ml-32 space-y-1">
                  <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
              <div>
              <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
              </div>
              <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                  </a>
            </div>
            </div>
          <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
          >
          <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
          </img>
          <p className="wrapword">{this.state.Isifiled[i]}</p>
        </button> 
        </button>
        )
      }
      else if (this.state.Extentiond[i]==="docx") {
        itemsd.push(
          <button name="Idedit" value={this.state.Idfiled[i]} onMouseEnter={this.handleChane} >

          <div>
            <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
              <div>
              <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
              </div>
              <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                  </a>
            </div>
            </div>
          <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
          >
          <FileIcon extension={this.state.Extentiond[i]}{...defaultStyles.docx}/>
          <p className="wrapword">{this.state.Isifiled[i]}</p>
        </button> 
        </button>
        )
      }
      else if (this.state.Extentiond[i]==="obb") {
        itemsd.push(
          <button name="Idedit" value={this.state.Idfiled[i]} onMouseEnter={this.handleChane} >

          <div>
            <div className="block absolute ml-32 space-y-1">
                  <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
              <div>
              <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
              </div>
              <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                  </a>
            </div>
            </div>
          <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
          >
          <FileIcon extension={this.state.Extentiond[i]}{...defaultStyles.obj}/>
          <p className="wrapword">{this.state.Isifiled[i]}</p>
        </button> 
        </button>)
      }
      else {
        itemsd.push(
          <button name="Idedit" value={this.state.Idfiled[i]} onMouseEnter={this.handleChane} >
          <div>
            <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
              <div>
              <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
              </div>
              <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                  </a>
            </div>
            </div>
          <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
          >
          <FileIcon extension={this.state.Extentiond[i]}/>
          <p className="wrapword">{this.state.Isifiled[i]}</p>
        </button> 
        </button>
        )
      }
    }
  }
  

  const folderd = []
  if (this.state.Isifolderd != null) {
    for (let i = 0; i < this.state.Isifolderd.length ; i++) {
      folderd.push(
        <>
        <button id="btn" name="Namefolder" onMouseEnter={this.handleChane} onClick={this.push} value={this.state.Isifolderd[i]} className="flex items-center px-2 space-x-2 bg-gray-200 w-40 h-10 rounded-lg m-2 focus:outline-none" type = "submit">
          <FaFolder size={20}/><p>{this.state.Isifolderd[i]}</p>
          <div className="ml-28 -space-y-2">
              <div>
               <button onClick={this.recoveryfolder}><FaEdit size={12}/></button>
              </div>
              <div>
               <button onClick={this.deletefolder}><FaTrash size={12}/></button>
              </div>
            </div>
        </button>
      </>
    )
    }  
  }
   
    
    const semuad = []
    if (this.state.Isisemuad != null) {
      for (let i = this.state.Panjangd; i < this.state.Isisemuad.length; i++) {
        semuad.push(
          <>
          <button id="btn" name="Namefolder" onMouseEnter={this.handleChane} onClick={this.push} value={this.state.Isisemuad[i]} className="flex items-center px-2 space-x-2 bg-gray-200 w-40 h-10 rounded-lg m-2 focus:outline-none" type = "submit">
            <FaFolder size={20}/><p>{this.state.Isisemuad[i]}</p>
            <div className=" -space-y-2">
              <div>
               <button onClick={this.recoveryfolder}><FaEdit size={12}/></button>
              </div>
              <div>
               <button onClick={this.deletefolder}><FaTrash size={12}/></button>
              </div>
            </div>
          </button>
        </>
        )
        
      }
    }
    
    for (let i = 0; i < this.state.Panjangd ; i++) {
    const src = "http://192.168.0.188:12345/download_file/?Username="+sessionStorage.getItem("Usernameuser")+"&Current_path=/"+this.state.Curren_path+"&File_name="+this.state.Isisemuad[i]
        if (this.state.Extentiond[i]== "mp4") {
            semuad.push(
              <button name="Idedit" value={this.state.Idisisemuad[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extentiond[i]}{...defaultStyles.mp4}/>
              <p className="wrapword">{this.state.Isisemuad[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extentiond[i]=="pdf") {
            semuad.push(
              <button name="Idedit" value={this.state.Idisisemuad[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
              
                  <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extentiond[i]}{...defaultStyles.pdf}/>
              <p className="wrapword">{this.state.Isisemuad[i]}</p>
            </button> 
            </button> 
            )
          }
          else if (this.state.Extentiond[i]==="jpg") {
            semuad.push(
              <button name="Idedit" value={this.state.Idisisemuad[i]} onMouseEnter={this.handleChane} >
                <div>
                  <div className="block absolute ml-32 space-y-1">
                  <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                    <div>
                    <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                    </div>
                    <a href={src}>
                      <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                    </a>
                  </div>
                  </div>
                <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
                >
                <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
                </img>
                <p className="wrapword">{this.state.Isisemuad[i]}</p>
              </button> 
              </button>
            )
          }
          else if (this.state.Extentiond[i]==="png") {
            semuad.push(
              <button name="Idedit" value={this.state.Idisisemuad[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
              </img>
              <p className="wrapword">{this.state.Isisemuad[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extentiond[i]==="jpeg") {
            semuad.push(
              <button name="Idedit" value={this.state.Idisisemuad[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
              </img>
              <p className="wrapword">{this.state.Isisemuad[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extentiond[i]==="gif") {
            semuad.push(
              <button name="Idedit" value={this.state.Idisisemuad[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
              </img>
              <p className="wrapword">{this.state.Isisemuad[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extentiond[i]==="docx") {
            semuad.push(
              <button name="Idedit" value={this.state.Idisisemuad[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extentiond[i]}{...defaultStyles.docx}/>
              <p className="wrapword">{this.state.Isisemuad[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extentiond[i]==="obb") {
            semuad.push(
              <button name="Idedit" value={this.state.Idisisemuad[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extentiond[i]}{...defaultStyles.obj}/>
              <p className="wrapword">{this.state.Isisemuad[i]}</p>
            </button> 
            </button>
            )
          }
          else {
            semuad.push(
              <button name="Idedit" value={this.state.Idisisemuad[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                  <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extentiond[i]}/>
              <p className="wrapword">{this.state.Isisemuad[i]}</p>
            </button> 
            </button>)
          }
    }
    // ---------------------------------------------------------------------------------------------ini akhir my drive
    // ----------------------------------------------------------------------------------------ini awal Search

    if (this.state.Isisemuas != null || this.state.Isisemuas != "" || this.state.Isisemuas != "undifined") {
      for (let i = this.state.Panjangs; i < this.state.Isisemuas.length; i++) {
        semuad.push(
          <>
          <button name="Idedit" onMouseEnter={this.handleChane} value={this.state.Isisemuas[i]} className="flex items-center px-2 space-x-2 bg-gray-200 w-40 h-10 rounded-lg m-2 focus:outline-none" type = "submit">
            <FaFolder size={20}/><p>{this.state.Isisemuas[i]}</p>
            <div className="absolute pl-28 -space-y-2">
              <div>
               <button onClick={this.recoveryfolder}><FaRecycle size={12}/></button>
              </div>
              <div>
               <button onClick={this.deletetrashfolder}><FaTrash size={12}/></button>
              </div>
            </div>
          </button>
        </>
        )
        
      }
    }
    if(this.state.Panjang != 0 ){
      for (let i = 0; i < this.state.Panjangs ; i++) {
        const src = "http://192.168.0.188:12345/download_file/?Username="+sessionStorage.getItem("Usernameuser")+"&Current_path=/&File_name="+this.state.Isisemuas[i]
        if (this.state.Extensis[i]== "mp4") {
            semuad.push(
              <button name="Idedit" value={this.state.Ids[i]} onMouseEnter={this.handleChane} >
                <div>
                  <div className="block absolute ml-32 space-y-1">
                  <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                    <div>
                    <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                    </div>
                    <a href={src}>
                        <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                        </a>
                  </div>
                  </div>
                <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
                >
                <FileIcon extension={this.state.Extensis[i]}{...defaultStyles.mp4}/>
                <p className="wrapword">{this.state.Isisemuas[i]}</p>
              </button> 
              </button>
        )
          }
          else if (this.state.Extensis[i]=="pdf") {
            semuad.push(
              <button name="Idedit" value={this.state.Ids[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                      <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                      </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extensis[i]}{...defaultStyles.pdf}/>
              <p className="wrapword">{this.state.Isisemuas[i]}</p>
            </button> 
            </button>)
          }
          else if (this.state.Extensis[i]==="jpg") {
            semuad.push(
              <button name="Idedit" value={this.state.Ids[i]} onMouseEnter={this.handleChane} >
                <div>
                  <div className="block absolute ml-32 space-y-1">
                  <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                    <div>
                    <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                    </div>
                    <a href={src}>
                      <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                    </a>
                  </div>
                  </div>
                <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
                >
                <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
                </img>
                <p className="wrapword">{this.state.Isisemuas[i]}</p>
              </button> 
              </button>
            )
          }
          else if (this.state.Extensis[i]==="png") {
            semuad.push(
              <button name="Idedit" value={this.state.Ids[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                  <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                      <h1 className="text-center">Rename File</h1>
                          <div className ="space-y-10">
                            <div>
                                <label>Masukkan Nama File</label>
                                <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                            </div>
                            <div>
                                  <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                            </div>
                          </div> 
                  </div>
                </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                    <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
              </img>
              <p className="wrapword">{this.state.Isisemuas[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extensis[i]==="jpeg") {
            semuad.push(
              <button name="Idedit" value={this.state.Ids[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                  <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                      <h1 className="text-center">Rename File</h1>
                          <div className ="space-y-10">
                            <div>
                                <label>Masukkan Nama File</label>
                                <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                            </div>
                            <div>
                                  <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                            </div>
                          </div> 
                  </div>
                </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                    <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
              </img>
              <p className="wrapword">{this.state.Isisemuas[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extensis[i]==="gif") {
            const src = "http://192.168.0.188:12345/download_file/?Username="+sessionStorage.getItem("Usernameuser")+"&Current_path=/&File_name="+this.state.Isisemuad[i]
            semuad.push(
              <button name="Idedit" value={this.state.Ids[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                  <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                      <h1 className="text-center">Rename File</h1>
                          <div className ="space-y-10">
                            <div>
                                <label>Masukkan Nama File</label>
                                <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                            </div>
                            <div>
                                  <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                            </div>
                          </div> 
                  </div>
                </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                    <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaDownload size={12}/></button>
                  </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <img className="w-full h-32 object-cover rounded-xl " src={src} alt="">
              </img>
              <p className="wrapword">{this.state.Isisemuas[i]}</p>
            </button> 
            </button>
            )
          }
          else if (this.state.Extensis[i]==="docx") {
            semuad.push(
              <button name="Idedit" value={this.state.Ids[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                      <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                      </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extensis[i]}{...defaultStyles.docx}/>
              <p className="wrapword">{this.state.Isisemuas[i]}</p>
            </button> 
            </button>)
          }
          else if (this.state.Extensis[i]==="obb") {
            semuad.push(
              <button name="Idedit" value={this.state.Ids[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                      <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                      </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extensis[i]}{...defaultStyles.obb}/>
              <p className="wrapword">{this.state.Isisemuas[i]}</p>
            </button> 
            </button>
            )
          }
          else {
            semuad.push(
              <button name="Idedit" value={this.state.Ids[i]} onMouseEnter={this.handleChane} >
              <div>
                <div className="block absolute ml-32 space-y-1">
                <Rename>
                    <div className="z-40 bg-white -ml-40 absolute rounded-lg w-70 h-50 shadow p-5 space-y-10">
                        <h1 className="text-center">Rename File</h1>
                            <div className ="space-y-10">
                              <div>
                                  <label>Masukkan Nama File</label>
                                  <input type="input" name="Rename" value={this.state.Rename} onChange={this.handleChane} className="border-2"></input>
                              </div>
                              <div>
                                    <button type="submit" onClick={(e)=>this.rename(e)} className="shadow px-3 py-2 rounded-lg">Create</button>
                              </div>
                            </div> 
                    </div>
                  </Rename>
                  <div>
                  <button  className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white" onClick={this.delete}><FaTrash size={12}/></button>
                  </div>
                  <a href={src}>
                      <button className="-ml-8 mt-1 bg-black text-white rounded-lg p-1 text-border-2 text-border-white"><FaDownload size={12}/></button>
                      </a>
                </div>
                </div>
              <button id="btn" className="mx-5 my-10 w-28 h-36 text-sm text-center rounded-lg focus:outline-none rounded" type = "submit"
              >
              <FileIcon extension={this.state.Extensis[i]}/>
              <p className="wrapword">{this.state.Isisemuas[i]}</p>
            </button> 
            </button>)
          }  
    }
    }
   
    // ----------------------------------------------------------------------------------------ini akhir Search
  return (
    <div>
      <div className=" fixed z-50 w-full bg-white shadow">
        <div className = "absolute flex bg-gray-300 rounded-lg items-center md:mt-5 mt-16 md:ml-96 ml-40 md:w-96 w-40  md:h-7 h-3 px-5">
              <button className="mx-2 w-20" onClick={this.search}><FaSearch /></button>
              <input className="bg-transparent w-70 h-5 focus:outline-none focus:w-96" type = "input"  placeholder = "Search" 
              name = "Key"
              value={this.state.Key}
              onChange = {this.handleChane}
              ></input>
              {this.state.Key}
            </div>
          <Navbar/>
            
      </div>
     
      <div className="container flex bg-white pt-20 py-14">
      {/* ------------------------------semua halaman */}
      <TabGroup numTabs={2}>
        <TabGroup.TabList>
        <div className = "fixed h-screen bg-white md:px-16 px-5 pt-8 md:w-1/4 w-10 z-40">
           {/* ------------------------------------------------mulai Sidebar */}
        <div>
          {/* -----------------------------------------Tambah */}
            <Add>
                <div id="list" className="bg-white rounded-lg p-4 w-56 mt-2 shadow absolute">
                    <Addfolder>
                      <Createfolder/>
                    </Addfolder>
                    <Uploadfolder>
                      <Upfolder/>
                    </Uploadfolder>
                    <Uploadfile>
                      <div>
                        <Upfile/>
                      </div>
                    </Uploadfile>
                </div> 
            </Add>
            {/* --------------------------------------------Tambah */}
        </div>
          {/* ------------------------------------------------awal 3 icon */}
          
              <div>
                {/* --------------------------------------------bungkus 2 */}
                <TabGroup.Tab index={0} className="block focus:outline-none">
                  <button className = "my-5 flex focus:outlibe-none" onClick={this.filterd}>
                      <FaHdd size = {30}/><a className="mx-4">My drive</a>
                  </button>
                </TabGroup.Tab>
                <TabGroup.Tab index={1} className="block focus:outline-none">
                  <div className = "my-5 flex" onClick={this.filter}>
                      <FaTrashAlt size = {30}/><a className="mx-4">Trash</a>
                  </div>
                </TabGroup.Tab>
                {/* --------------------------------akhir bungkus */}
              </div>
              <div className = "flex my-36">
                <FaServer size = {60}/><p className="mx-4">Penyimpanan {this.state.courses}</p>
              </div>
          {/* ------------------------------------------akhir sidebar */}
        </div>
        <div className="z-10 fixed flex md:h-16 h-10 md:ml-96 ml-40 w-full bg-white border-b-2 border-gray-200 items items-center">
          {/* ..........................Navber kedua */}
          <div className="flex md:pt-2 pt-5">
              <div>
                <select className="bg-white  md:w-20 w-10 md:h-10 h-5 md:text-xl items-center focus:outline-none "
                  name="Idxfilter"
                  value={this.state.Idxfilter}
                  onChange={this.handleChane}
                  // onClick={this.getMydrive}
                  >
                    <option value={0}>All</option>
                    <option value={1}>Folder</option>
                    <option value={2}>File</option>
                  </select>
                </div> 
                <div className="md:pt-2">
                  <button className="bg-black opacity-60 text-white md:mx-5 mx-1 md:w-14 w-10 md:h-8 h-5 md:text-xl text-sm shadow rounded-lg focus:outline-none" onClick={this.filterd} >Filter</button>
                </div>
                <div className="flex w-11/12 justify-end">
                  <div className="md:m-2 px-2 py-1 items-center h-8 rounded-lg text-sm">{"/"+sessionStorage.getItem("Current")}</div>
                <div>
                  <button className="sm:absolute z-50 flex bg-black opacity-60 text-white item-center md:py-2 md:m-2 ml-10 z-50 w-20 md:h-8 h-6 shadow rounded-lg focus:outline-none p-1" onClick={this.hapus}>
                    <div className="flex">
                    <FaArrowAltCircleLeft/>
                    </div>
                    <div className="flex mx-2 -my-1">
                    <p>back</p>
                    </div>
                  </button>
                </div>  
                
              </div>  
            </div>
                  
        </div>
        

        </TabGroup.TabList>
        <div className= "z-0 md:ml-96 ml-40 mt-20 h-screen">
          {/* -------------------------------------isi  */}
        <TabGroup.TabPanel
          index={0}
          className="transition-all transform h-64"
          activeClassName="opacity-100"
          inactiveClassName="absolute opacity-0 translate-x-2"
        >
          
          {this.state.Idxfilter ==0 &&
                 <div className="flex flex-wrap items-center">
                 {semuad}
                 </div>
                  }
                  {this.state.Idxfilter ==1 &&
                  <>
                  <div className="block">
                    <div>
                  <p>Folder</p>
                  </div>
                   
                  <div className="flex flex-wrap my-5 mx-10">         
                  {folderd}
                  </div>
                  </div>  
                  </>

                  }
                  {this.state.Idxfilter ==2 &&
                  <>
                  <div className="block">
                  <p >File</p>
                  </div>
                  <div className="flex flex-wrap">         
                  {itemsd}
                  </div>   
                  </>                  
                  }
        </TabGroup.TabPanel>
        <TabGroup.TabPanel
          index={1}
          className="transition-all transform h-64 flex flex-col"
          activeClassName="opacity-100"
          inactiveClassName="absolute opacity-0 translate-x-2"
        >
           <div className="flex flex-wrap">
                {semua}
            </div>
        </TabGroup.TabPanel>
        </div>
        </TabGroup>
      
      </div>
      
      
      {/* -------------------batas akhir */}
    </div>
  )
}
}

export default Coba