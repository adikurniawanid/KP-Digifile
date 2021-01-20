import React, {useState } from 'react';
// import React, from 'react';

import Table from '../../components/molekul/table/table'
import Navbarowner from '../../components/molekul/navbarowner/navbarowner';
import { Add } from '../../components';
import DatePicker from 'react-datepicker';
import 'react-datepicker/dist/react-datepicker.css'
import { FaSearch } from "react-icons/fa"


// class Owner extends Component{
  function Owner() {
  // state = {
   
    const [selectStartDate, setSelectStartDate] = useState(null);
    const [selectEndDate, setSelectEndDate] = useState(null);

  // render(){
  return (
    <div className="block bg-gray-200 w-full h-screen">
        {/* <div className="fixed w-full"> */}
          <Navbarowner/>
        {/* </div> */}
        <div className="container bg-white w-3/4 m-auto mt-16 rounded-lg py-2 shadow">
          <div className="flex justify-between items-center px-5 py-5">
            <div>
            <Add/>
            </div>
            <div>
              <form className="flex">
                <div className="block w-40 mx-5">
                  <div>
                  <label>Nama</label>
                  </div>
                  <div className="flex rounded-lg border-2 shadow w-full">
                    <FaSearch/>
                  <input type="input" className="rounded-lg w-full text-xs focus:outline-none"></input>
                  </div>
                </div>
                <div className="block w-36 mx-5">
                  <div>
                  <label>Activity</label>
                  </div>
                  <div>
                    <select className="bg-white rounded-lg border-2 shadow text-xs focus:outline-none">
                      <option>Create folder</option>
                      <option>Delete Folder</option>
                      <option>Delete Folder</option>
                    </select>
                  {/* <input type="input" className="rounded-lg border-2 shadow w-full"></input> */}
                  </div>
                </div>

                <div className="block w-36 mx-5">
                  <div>
                  <label>Start Date</label>
                  </div>
                  {/* <div> */}
                  <div type="input" className="rounded-lg border-2 shadow w-full text-xs focus:outline-none">
                        <DatePicker className="w-full focus:outline-none text-center"
                        name="startdate"
                        // value={this.state.startdate}
                        selected={selectStartDate} 
                        onChange={date => setSelectStartDate(date)} 
                        dateFormat="yyyy-MM-dd"
                        maxDate={new Date()}
                        showMonthDropdown
                        showYearDropdown/>
                        
                  </div>
                  {/* <input type="input" className="rounded-lg border-2 shadow w-full "></input> */}
                  {/* </div> */}
                </div>

                <div className="block w-36 mx-5">
                  <div>
                  <label>End Date</label>
                  </div>
                  <div type="input" className="rounded-lg border-2 shadow w-full text-xs focus:outline-none">
                        <DatePicker className="w-full focus:outline-none text-center"
                        name="enddate"
                        // value={this.state.enddate}
                        selected={selectEndDate} 
                        onChange={date => setSelectEndDate(date)} 
                        dateFormat="yyyy-MM-dd"
                        maxDate={new Date()}
                        showMonthDropdown
                        showYearDropdown/>
                  </div>
                </div>
                
              </form>
            </div>
          </div>
          <Table/>
          <div className="bg-red-400 px-5">
            tabel 1 dari 1
          </div>
          
        </div>
    </div>
  );
  // }

}

export default Owner;