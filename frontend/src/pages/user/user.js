import React from 'react';
import { Divfolder, Navbar, Sidebar, Divfile } from '../../components/molekul';


function User() {
  return (
    <div>
      {/* <Addfolder/> */}
      <div className="fixed w-full">
          <Navbar/>
      </div>
      <div className="container flex bg-white py-24">
          <Sidebar/>
          <div className="w-full bg-white">
            <div className="fixed h-16 ml-96 -mt-3 w-full bg-white border-b-2 border-gray-200 items items-center">
              
              <select className="bg-white w-20 h-10 text-xl items-center focus:outline-none ">
                <option>All</option>
                <option>Folder</option>
                <option>File</option>
              </select>
            </div>
            <div className="ml-96 space-y-20">
              <div className="mt-14">
                <Divfolder/>
              </div>
              <div>
                <Divfile/>
              </div>
                
            </div>
          </div>
      </div>
    </div>
  );
}

export default User;