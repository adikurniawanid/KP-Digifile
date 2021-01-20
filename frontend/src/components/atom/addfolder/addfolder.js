import React from 'react';


function Addfolder(props) {
    return(
        <div className="items-center">
            <div className="bg-black opacity-50 w-full h-screen items-center pt-40 ">
            
            </div>
            <div className="bg-white rounded-lg w-1/2 h-40 mx-center absolute -mt-96 ml-96 m-20 p-5">
             <form className="space-y-4 ml-48">    
                 <label className="block">
                     Nama Folder
                 </label>
                 <input className="rounded-lg focus:outline-none border-2 block" placeholder="masukkan nama folder"></input>
                 <button className="bg-gray-200 rounded-lg py-1 px-2 ml-96" type="submit"> OK </button>
             </form>
            </div>
      </div>
    )
}

export default Addfolder
