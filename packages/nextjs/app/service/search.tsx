'use client'
import { useSearchParams } from 'next/navigation'
import QRCode from "qrcode.react";
import { useState, useEffect } from "react";
 
export default function SearchBar() {
  const searchParams = useSearchParams()
  const [qrCodeDataURL, setQrCodeDataURL] = useState<string | null>(null);
  const search = searchParams.get('search')

  const generateQRCodeViem = async (to: string, amount: string) => {
    setQrCodeDataURL(`https://localhost:3000/?${search}=value1`);
  };

  useEffect(() => {
    generateQRCodeViem("", "");
  }, []);
 
  // This will not be logged on the server when using static rendering
  const handleClick = () => { 
    console.log('Button clicked');  
    console.log('search', search); 
  }

  handleClick();
 
  return <>{qrCodeDataURL && <QRCode value={qrCodeDataURL} />}{search}</>
}