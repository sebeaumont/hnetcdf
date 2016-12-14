{-# LANGUAGE ForeignFunctionInterface #-}

-- | FFI utility functions for raw bindings.

module Data.NetCDF.Raw.Utils
       ( module Data.NetCDF.Raw.Utils
       , module Foreign.C
       , module Foreign.Ptr
       , module Foreign.Storable
       , module Foreign.Marshal.Array
       , module Foreign.Marshal.Alloc
       , unsafePerformIO
       ) where

import Control.Monad (liftM)
import Foreign.C
import Foreign.Ptr
import Foreign.Storable
import Foreign.Marshal.Array
import Foreign.Marshal.Alloc
import System.IO.Unsafe (unsafePerformIO)

ncMaxName, ncMaxDims, ncMaxVars, ncMaxAttrs, ncMaxVarDims :: Int
ncMaxName = 256
ncMaxDims = 1024
ncMaxVars = 8192
ncMaxAttrs = 8192
ncMaxVarDims = 1024


-- | FFI utilities

peekIntConv :: (Storable a, Integral a, Integral b) => Ptr a -> IO b
peekIntConv = liftM fromIntegral . peek

peekFloatConv :: (Storable a, RealFloat a, RealFloat b) => Ptr a -> IO b
peekFloatConv = liftM realToFrac . peek

withIntArray :: Integral a => [a] -> (Ptr CInt -> IO b) -> IO b
withIntArray = withArray . liftM fromIntegral

withIntPtrConv :: (Storable b, Integral a, Integral b)
                  => a -> (Ptr b -> IO c) -> IO c
withIntPtrConv val f =
  alloca $ \ptr -> do
    poke ptr (fromIntegral val)
    f ptr

withFloatPtrConv :: (Storable b, RealFloat a, RealFloat b)
                    => a -> (Ptr b -> IO c) -> IO c
withFloatPtrConv val f =
  alloca $ \ptr -> do
    poke ptr (realToFrac val)
    f ptr

withCStringPtr :: String -> (Ptr CString -> IO a) -> IO a
withCStringPtr val f =
  withCString val $ \inner -> do
    alloca $ \outer -> do
      poke outer inner
      f outer

allocaName :: (Ptr a -> IO b) -> IO b
allocaName = allocaBytes ncMaxName

allocaVarDims :: (Ptr CInt -> IO b) -> IO b
allocaVarDims = allocaArray ncMaxVarDims
peekVarDims :: Ptr CInt -> IO [Int]
peekVarDims = liftM (map fromIntegral) . peekArray ncMaxVarDims
