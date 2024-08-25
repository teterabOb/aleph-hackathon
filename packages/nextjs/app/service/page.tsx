"use client";
import { useEffect, useState } from "react";
import { Suspense } from 'react'
import SearchBar from './search'

function SearchBarFallback() {
    return <>placeholder</>
}

export default function Payment() {

  return (
    <div>
      <h1>Dynamic QR Code Generator</h1>
        <Suspense fallback={<SearchBarFallback />}>
          <SearchBar />
        </Suspense>
    </div>
  );
}
