import React,{Component} from 'react';
import { Edit } from '../../atom';
import axios from 'axios'
import Klikedit from '../../atom/kilikedit/klikedit';

class Table extends Component{
  state = {
    courses : [],
};

componentWillMount(){
    const url = 'http://192.168.8.100:12345/get_log_activity/'
    axios.get(url).then(res => {
        console.log(res.data);
        this.setState({courses : res.data.data})
    }).catch(error => {
        console.log(error)
    })
}
  render(){
    let i =1;
    return(    
        <table class="table-fixed" className="mx-10 mb-10 text-center "> 
        <thead>
          <tr className="bg-gray-200">
            <th className="w-10">No</th>
            <th className="w-1/4">Name</th>
            <th className="w-1/4">Last Activity Date</th>
            <th className="w-1/4">Last Activity</th>
            <th className="w-1/6">Kuota</th>
            <th className="w-1/6">Status</th>
            <th className="w-10">Edit</th>
          </tr>
        </thead>
        <tbody className="align-items-center">
        {
        this.state.courses.map((basing) => {
             return(
             <tr>
                <td>{i++}</td>
                <td>{basing.name}</td>
                <td>{basing.tanggal}</td>
                <td>{basing.last_activity}</td>
                <td>{basing.kuota}</td>
                <td>{basing.status}</td>
                <td><Edit>
                  </Edit></td>
             </tr>
             )
         
     })}
        </tbody>
      </table>
    )
}
}

export default Table