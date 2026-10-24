#!/usr/bin/env python3
import importlib.util, subprocess, tempfile, unittest
from pathlib import Path
from unittest.mock import patch
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('gate',HERE/'check-no-gpl.py');gate=importlib.util.module_from_spec(spec);spec.loader.exec_module(gate)
class GateTests(unittest.TestCase):
 def inspect(self,name,data,dependencies=''):
  with tempfile.TemporaryDirectory(dir=HERE) as t:
   p=Path(t)/name;p.parent.mkdir(parents=True,exist_ok=True);p.write_bytes(bytes.fromhex('cffaedfe')+data)
   with patch.object(gate.subprocess,'run',return_value=subprocess.CompletedProcess([],0,'test:\n'+dependencies,'')):
    return gate.inspect((p,name,bytes.fromhex('cffaedfe')))
 def test_rejects_gpl_named_library(self):
  issues,_=self.inspect('libx264.164.dylib',b'');self.assertIn('known-gpl-name',[x['check'] for x in issues])
 def test_rejects_hidden_dependency(self):
  issues,_=self.inspect('innocent.dylib',b'', '\t@rpath/libx265.215.dylib (compatibility version 1.0.0)\n');self.assertIn('known-gpl-dependency',[x['check'] for x in issues])
 def test_rejects_embedded_gpl_flag(self):
  issues,_=self.inspect('libavcodec.63.dylib',b'\0--prefix=/safe --enable-gpl\0');self.assertIn('ffmpeg-gpl-nonfree-flag',[x['check'] for x in issues])
 def test_rejects_nonfree_flag(self):
  issues,_=self.inspect('libavcodec.63.dylib',b'\0--prefix=/safe --enable-nonfree\0');self.assertIn('ffmpeg-gpl-nonfree-flag',[x['check'] for x in issues])
 def test_lgpl_flags_pass(self):
  issues,record=self.inspect('libavcodec.63.dylib',b'\0--prefix=/safe --disable-gpl --disable-nonfree --enable-shared\0');self.assertEqual(issues,[]);self.assertTrue(record['ffmpeg_configurations'])
 def test_unverified_avcodec_configuration_fails(self):
  issues,_=self.inspect('libavcodec.63.dylib',b'\0');self.assertIn('ffmpeg-configuration-unverified',[x['check'] for x in issues])
 def test_plugin_gpl_field(self):
  issues,_=self.inspect('gstreamer-1.0/libgstbad.dylib',b'\0GPL\0');self.assertIn('gstreamer-gpl-license',[x['check'] for x in issues])
 def test_plugin_lgpl_field(self):
  issues,_=self.inspect('gstreamer-1.0/libgstgood.dylib',b'\0LGPL\0');self.assertEqual(issues,[])
 def test_dev_gptk_projection(self):
  self.assertTrue(gate.projected_out(Path('d3dmetal.dll'),'Contents/Resources/d3dmetal/d3dmetal.dll',b''))
  self.assertTrue(gate.projected_out(Path('nvapi64.dll'),'Contents/Resources/Wine/lib/wine/x86_64-windows/nvapi64.dll',b'D3DMetalDLLsBase'))
if __name__=='__main__':unittest.main()
