import React, {useState} from 'react';



function File(props) {
    const [open, setOpen]=useState(false);
    return(
        <div>
        <button onClick={()=>setOpen(!open)} id="btn" className = "bg-grey-200 w-32 h-46 m-5 focus:outline-none" type = "submit">
            <img className="w-full h-32 object-cover " src="https://upload.wikimedia.org/wikipedia/en/d/de/The_Promised_Neverland.jpg" alt="">
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

