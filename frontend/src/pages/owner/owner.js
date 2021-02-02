import React from 'react';
import Navbarowner from '../../components/molekul/navbarowner/navbarowner';
import { Add, Akun, Edit, Klikedit} from '../../components';
import 'react-datepicker/dist/react-datepicker.css'
import { FaSearch} from "react-icons/fa"
import {  Component } from 'react';
import axios from 'axios';
import { TabGroup } from '@statikly/funk'
import { FaUsers } from "react-icons/fa";


class Owner extends Component{
    state = {
      Name : "",
      Activity_id : "1",
      Start_date : "01-01-1950",
      End_date : "01-01-2077",
      courses : null,
      Username:[],
      idx:null,
      Activity:null,

      Split : null,
      Page : 1,
      Many : 1,


      inputUsername : null,
      inputNama : null,
      inputEmail : null,
      inputSpace : null,
      editcourses : null,

      Usernameedit : null,
      Nama : null,
      Email : null,
      Space : null,
      Edituser : null,
    }
    
    handleChange = e => {
      this.setState({
        [e.target.name] : e.target.value
      })
    }

    changeIdx = e => {
      this.setState({
        idx : e.target.value
      })
    }

    changeEdit = e => {
      this.setState({
        idx : e.target.value
      })
    }

    componentWillMount=()=>{
      const url = 'http://192.168.0.188:12345/get_log_activity/'
      axios.get(url).then(res => {
          this.setState({courses : res.data.data })
          this.setState({Username : res.data.data1})
          console.log(this.state.Username)
      }).catch(error => {
          console.log(error)
      })
    }
    userinformation=()=>{
      axios.get('http://192.168.0.188:12345/get_user_information/?',{params :{
        Username : this.state.Edituser
        }}).then(res=>{
          this.setState({
            Usernameedit : res.data.Username,
            Nama : res.data.Name,
            Email : res.data.Email,
            Space : res.data.Space
          })
          console.log(res)
        },(err)=>{
            console.log("gagal")
        }
        )
    }

    handleSubmit=()=>{
      axios.get('http://192.168.0.188:12345/search/',{params :{
        Name : this.state.Name,
        Activity_id : this.state.Activity_id,
        Start_date : this.state.Start_date,
        End_date : this.state.End_date,
        }}).then(res=>{
          this.setState({courses : res.data.data})
          this.setState({Username : res.data.data1})
          console.log(res)
        },(err)=>{
            console.log("gagal untuk search")
        }
        )
    }
    logs=()=>{  
      axios.get('http://192.168.0.188:12345/logs/',{params :{
        Username : this.state.Username[this.state.idx-1],
        Page : this.state.Page
        }}).then(res=> {
          this.setState({Split:res.data.data})
          this.setState({Activity : res.data.data1})
          this.setState({
          Many :  Math.ceil(this.state.Split / 10)
        })
    }
        )
    }
    getAktivity=()=>{  
      axios.get('http://192.168.0.188:12345/get_user_log_activity/',{params :{
        Username : this.state.Username[this.state.idx-1],
        Page : this.state.Page
        }}).then(res=> {
          this.setState({Activity:res.data.data})
          console.log("--------page-------", this.state.Page)
          console.log("--------page-------", res)
    }
        )
    }

    async handleEdit(){
      const params = new URLSearchParams()
      params.append('Username', this.state.Username[this.state.idx-1])
      params.append('Name', this.state.inpuNama)
      params.append('Space', this.state.inpuSpace)
      params.append('Email', this.state.inputEmail)
      await axios.put('http://192.168.0.188:12345/edit_user/',params)
        .then(res =>{
          console.log(res)
        })
        this.replace()
    }
    handleEdituser=()=>{
      const params = new URLSearchParams()
        params.append('Username', this.state.Usernameedit)
        params.append('Name', this.state.Nama)
        params.append('Space', this.state.Space)
        params.append('Email', this.state.Email)
      axios.put('http://192.168.0.188:12345/edit_user/',params)
          .then(res =>{
            console.log(res)
          })
          // this.replace()
      }
    replace(){
      window.location.reload()
    }

  render(){
    let i =0;
    let ah = 0;
    const items = []
    for (let index = 1; index <= this.state.Many; index++) {
      items.push(<option value={index}>{index}</option>)
      
    }

    if(sessionStorage.getItem("Usernameowner")===null){
      this.props.history.push("/")
    }
  return (
    <div className="md:fixed block bg-gray-200 w-full h-screen">
        {/* <div className="fixed w-full"> */}
          <Navbarowner/>
        {/* </div> */}
        <TabGroup numTabs={2} direction={TabGroup.direction.HORIZONTAL}>
        <TabGroup.TabList className="z-0">
          <div className="mt-8 md:ml-48 absolute flex">
          <TabGroup.Tab
            index={0}
            className="flex mr-2 py-2 md:w-56 w-26 h-10 rounded-r-lg transition-colors duration-150 focus:outline-none"
            activeClassName="bg-white"
            inactiveClassName="bg-gray-400 text-black"
          >
            <FaUsers className="flex-row md:mx-5 mx-2" size={20}/> All User
          </TabGroup.Tab>
          <TabGroup.Tab
            index={1}
            className="flex mr-2 py-2 md:w-56 w-26 h-10 p-5 rounded-r-lg transition-colors duration-150 focus:outline-none"
            activeClassName="bg-white"
            inactiveClassName="bg-gray-400 text-black"
          >
            <FaUsers className="flex md:mx-5 mx-2" size={20}/> <p>Activity User</p>
          </TabGroup.Tab>
          <TabGroup.Tab
            index={2}
            className="flex mr-2 py-2 md:w-56 w-26 h-10 p-5 rounded-r-lg transition-colors duration-150 focus:outline-none"
            activeClassName="bg-white"
            inactiveClassName="bg-gray-400 text-black"
          >
            <FaUsers className="flex md:mx-5 mx-2" size={20}/> <p>Edit User</p>
          </TabGroup.Tab>
          </div>
        </TabGroup.TabList>

        <div className="container bg-white md:h-96 h-screen md:w-3/4 w:full m-auto mt-16 md:ml-48 rounded-lg py-2 shadow absolute">
        <TabGroup.TabPanel
          index={0}
          className="transition-all transform h-64"
          activeClassName="opacity-100 duration-500 translate-x-0"
          inactiveClassName="absolute opacity-0 -translate-x-2"
        >
          <div className="flex justify-between items-center px-5 mt-10 pb-5"> 
          <div>
            <Add>

              <Akun/>

            </Add>
            </div>

            <div>
              <div className="md:flex block">
                <div className="block w-36 mx-2">
                  <div>
                  <label>Nama</label>
                  </div>
                  <div className="flex rounded-lg border-2 shadow w-full">
                    <FaSearch/>
                  <input type="input" className="rounded-lg w-full text-xs focus:outline-none"
                  name="Name"
                  value={this.state.Name}
                  onChange={this.handleChange}></input>
                  </div>
                </div>
                <div className="block w-36 mx-2">
                  <div>
                  <label>Activity</label>
                  </div>
                  <div>
                    <select className="bg-white rounded-lg border-2 shadow text-xs focus:outline-none"
                    name="Activity_id"
                    value={this.state.Activity_id}
                    onChange={this.handleChange}>   
                      <option value={1}>Create Folder</option>
                      <option value={2}>Upload Folder</option>
                      <option value={3}>Rename Folder</option>
                      <option value={4}>Delete Folder</option>
                      <option value={5}>Recovery Folder</option>
                      <option value={6}>Upload File</option>
                      <option value={7}>Delete File</option>
                      <option value={8}>Rename File</option>
                      <option value={9}>Recovery Filer</option>
                    </select>
                  </div>
                </div>

                <div className="block w-36 mx-2">
                  <div>
                  <label>Start Date</label>
                  </div>
                  <div type="input" className="rounded-lg border-2 shadow w-full text-xs focus:outline-none">
                    <input type="date"
                    name="Start_date"
                    onChange={this.handleChange}
                    ></input>

                  </div>
                  
                </div>

                <div className="block w-36 mx-2">
                  <div>
                  <label>End Date</label>
                  </div>
                  <div type="input" className="rounded-lg border-2 shadow w-full text-xs focus:outline-none">
                  <input type="date"
                  name="End_date"
                  onChange={this.handleChange}
                  ></input>
                  </div>
                </div>
                <div className="block mx-2 items-center">
                  <button className="bg-green-400 rounded-lg shadow px-2 text-white mt-6"
                  onClick={this.handleSubmit}>Search</button>
                </div>
              </div>
            </div>
            </div>


            <table classname="table-fixed" className="md:mx-10 mb-10 text-center"> 
              <thead>
                <tr className="bg-gray-200">
                  <th className="w-10">No</th>
                  <th className="w-1/4">Name</th>
                  <th className="w-1/4">Last Activity Date</th>
                  <th className="w-1/4">Last Activity</th>
                  <th className="w-1/6">Kuota</th>
                  <th className="w-1/6">Status</th>
                </tr>
              </thead>
              <tbody className="align-items-center">
              { this.state.courses != null && 

              this.state.courses.map((basing) => {
                {i++}
                  return(
                  <tr>
                      <td>{i}</td>
                      <td name="idx" value={this.state.idx}>
                        <TabGroup.Tab
                        index = {1}   
                        >
                          <button value={i} onMouseEnter={this.changeIdx} onClick={this.logs}>
                          {basing.name}
                          </button>
                        </TabGroup.Tab>  
                      </td>
                      <td>{basing.tanggal}</td>
                      <td>{basing.last_activity}</td>
                      <td>{basing.kuota}</td>
                      <td>{basing.status}</td>      
                  </tr>
                  )
              
          })}
          </tbody>
       
          </table>
          { this.state.courses == null && 
            <div className="px-5 text-center items-center">
              <p className="m-auto font-bold text-2xl text-gray-200">Tidak Ada Data</p>
              <div>
                <button onClick={this.replace} className="shadow rounded-lg px-5 py-2">Refresh</button>
              </div>
            </div>
          }
          
          <div className="bg-red-400 px-5 mt-10 text-center">
            <p className="m-auto font-bold">Digital Creative</p>
          </div>
        </TabGroup.TabPanel>
        <TabGroup.TabPanel
          index={1}
          className="items-center transition-all transform h-64 flex flex-col"
          activeClassName="opacity-100 duration-500 translate-x-0"
          inactiveClassName="absolute opacity-0 -translate-x-2"
        >
        <div className="mt-5 w-full items-center">
        {/* <div className="m-auto font-bold text-xl">Activity Person</div> */}
        <table classname="table-auto" className="mb-10 w-full text-center p-2"> 
        <thead>
          <tr className="bg-gray-200">
            <th className="w-5 px-5">No</th>
            <th className="w-1/2 px-5">Tanggal</th>
            <th className="w-1/2 px-5">Last Activity</th>
          </tr>
        </thead>
        <tbody className="align-items-center">
        { this.state.Activity != null && 
              this.state.Activity.map((basing) => {
                {ah++}
                   return(
                   <tr className="border-2">
                      <td>{ah}</td>
                      <td>{basing.tanggal}</td>
                      <td className ="text-left">{basing.last_activity}</td>
                   </tr>
                   )
              
              }
            )
          }
     </tbody>
     </table>
  
     <div className="bg-red-400 flex justify-between px-5 -mt-10 w-full ">
       <div>
         <p className="text-white">Halaman {this.state.Page} Dari {this.state.Many}</p>
       </div>
            <div className = "text-center">
                <p className="m-auto font-bold">Digital Creative</p>
            </div>
            <div className="w-30 h-7  bg-white space-x-5 px-2">      
                <select name="Page" value={this.state.Page} onChange={this.handleChange} className="w-10 bg-white focus:outline-none">
                  {items}
                </select>
                <button onClick={this.getAktivity} className="px-2 shadow bg-gray-200 rounded-lg"> Submit </button>
            </div>
          </div>
          { this.state.Activity == null && 
              <div className="px-5 text-center items-center mt-20">
                <p className="m-auto font-bold text-2xl text-gray-200">Tidak Ada Data</p>
            </div>
          }
     </div>
     
        </TabGroup.TabPanel>
        <TabGroup.TabPanel
          index={2}
          className="transition-all transform h-64"
          activeClassName="opacity-100 duration-500 translate-x-0"
          inactiveClassName="absolute opacity-0 -translate-x-2"
        >
           <h1 className = "bg-gray-200 text-2xl text-shadow-md font-bold text-center">Edit</h1>
          <div className="flex justify-between w-full px-5 mt-10 pb-5"> 
          <div className="flex px-5 mt-5 text-center">
            <div className="text-center w-40 rounded-lg">
              <table className="text-center space-y-2 w-40 h-auto rounded-lg h-10 overscroll-auto">
                  <tr className="bg-gray-200">Daftar Username</tr>

                  {this.state.Username != null &&
                  
                    this.state.Username.map((basing) => {
                      {i++}
                        return(
                            <tr><button name="Edituser" value={basing} onMouseEnter={this.handleChange} onClick={this.userinformation} >{basing}</button></tr>
                        )  
                })
                
                  }
                </table>
              </div>
          </div>
            <div>
            <div id="list" className="bg-white rounded-lg shadow pt-5">
                {/* <form> */}
                  <div className = "flex">
                    <div className = "block text-center"> 
                      <label className="block font-bold text-blue-400">Username</label>
                      <input className = "text-gray-400 shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = "Username"
                      disabled
                      name="Usernameedit"
                      value={this.state.Usernameedit}
                      onChange={this.handleChange}>
                    </input>
                    </div>
                    <div className = "block text-center">
                      <label className="block font-bold text-blue-400">Nama</label>
                      <input className = "shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = "Nama" 
                      name="Nama"
                      value={this.state.Nama}
                      onChange={this.handleChange}>
                      </input>
                    </div>                    
                  </div>
                  <div className="flex">
                    <div className = "block text-center">
                      <label className="block font-bold text-blue-400">Email</label>
                      <input className = "shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "text" placeholder = "Email"
                      name="Email"
                      value={this.state.Email}
                      onChange={this.handleChange}>
                      </input>
                    </div>
                    <div className = "block text-center">
                      <label className="block font-bold text-blue-400">Space</label>
                      <input className = "shadow bg-white-100 rounded-lg w-3/4 h-10 text-grey-100 font-bold p-4 mb-5 placeholder-gray-200::placeholder focus:outline-none" type = "number" placeholder = "Masukkan bilangan integer" 
                      name="Space"
                      value={this.state.Space}
                      onChange={this.handleChange}>
                      </input>
                    </div>

                  </div>
                    <div className="text-center">
                    <button className ="bg-gray-200 shadow my-2 py-1 px-2 rounded-lg font-bold m-auto" 
                    type = "submit"
                    onClick = {this.handleEdituser}
                    >Edit</button>
                    </div>
                {/* </form>    */}
              </div>
          </div>
          </div>

        
          
          <div className="bg-red-400 px-5 mt-5 text-center">
            <p className="m-auto font-bold">Digital Creative</p>
          </div>
        </TabGroup.TabPanel>

       
        </div>
        </TabGroup>
    </div>
      
  );
  }

}

export default Owner