import React, {useState} from 'react';



function File(props) {
    const [open, setOpen]=useState(false);
    return(
        <div>
        <button onClick={()=>setOpen(!open)} id="btn" className = "bg-grey-200 w-32 h-46 m-5 focus:outline-none" type = "submit">
            <img className="w-full h-32 object-cover " src="http://192.168.0.188:12345/download_file/?Username=rsf&Current_path=/&File_name=logo%20uread.png" alt="">
            </img>
            <div className="bg-gray-200 w-full h-10 rounded-b-lg items-center">
            <p>{props.text}</p>
            </div>
        </button>
        {open && props.children}
        </div>
    )
}

export default File

