import React,{Component} from 'react';
import { Edit } from '../../atom';

class Table extends Component{
  
  // state = {
  //   tanggal : new Date()
  // };

 
  // document.getElementById("hasil").innerHTML = tanggal;
  render(){
    return(    
        <table class="table-fixed" className="mx-10 mb-10 text-center "> 
        <thead>
          <tr className="bg-gray-200">
            <th className="w-10">No</th>
            <th className="w-1/3">Last Activity Date</th>
            <th className="w-1/3">Last Activity</th>
            <th className="w-1/5">Kuota</th>
            <th className="w-1/5">Status</th>
            <th className="w-10">Edit</th>
          </tr>
        </thead>
        <tbody className="align-items-center">
          <tr className="bg-white">
            <td className="p-auto">1</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td><Edit/> </td>
          </tr>
          <tr className="bg-gray-200">
            <td className="p-auto">2</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td><Edit/></td>
          </tr>
          <tr className="bg-white-200">
            <td className="p-auto">3</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td><Edit/></td>
          </tr>
          <tr className="bg-gray-200">
            <td className="p-auto">4</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td><Edit/></td>
          </tr>
          <tr className="bg-white-200">
            <td className="p-auto">5</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td><Edit/></td>
          </tr>
          <tr className="bg-gray-200">
            <td className="p-auto">6</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
          <tr className="bg-white-200">
            <td className="p-auto">7</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
          <tr className="bg-gray-200">
            <td className="p-auto">8</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
          <tr className="bg-white-200">
            <td className="p-auto">9</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
          <tr className="bg-gray-200">
            <td className="p-auto">10</td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
            <td></td>
          </tr>
        </tbody>
      </table>
    )
}
}

export default Table