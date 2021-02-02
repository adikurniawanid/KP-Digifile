// import React from 'react';
// import { Component } from 'react';
// import { FaSearch } from "react-icons/fa"
// import axios from 'axios'

// class Search extends Component {
//     state = {
//         Key : "",
//         Folder : [],
//         Isisemuas :[],
//         Panjangs : null,
//         Extensis : [],
//         Ids : []
//     }

//     handleChange = e => {
//         this.setState({
//           [e.target.name] : e.target.value
//         })
//         console.log(this.state.Key)
//       }
//       search(){
//         axios.get('http://192.168.0.188:12345/search_user/',{params :{
//             Username : sessionStorage.getItem("Username"),
//             Item_name : this.state.Key
//             }}).then(res=>{
//               this.setState({Isisemuas : res.data.data})
//               this.setState({Panjangs : res.data.file})
//               this.setState({Extensis : res.data.ekstensi})
//               this.setState({Ids : res.id})
//               console.log(res)
//             },(err)=>{
//                 console.log("gagal untuk search")
//             }
//             )
        
//       }
//     render(){    
//     return(
//         <div className = "search flex bg-gray-300 rounded-lg items-center w-96 h-7 mx-10 px-5">
//             <button className="mx-2 w-20" onClick={this.search}><FaSearch /></button>
//             <input className="bg-transparent w-70 h-5 focus:outline-none focus:w-96" type = "input"  placeholder = "Search" 
//             name = "Key"
//             value={this.state.Key}
//             onChange = {this.handleChange}
//             ></input>
//             {this.state.Key}
//         </div>
        
//     )
//     }

// }

// export default Search