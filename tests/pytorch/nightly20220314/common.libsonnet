// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

local common = import '../common.libsonnet';
local experimental = import '../experimental.libsonnet';
local mixins = import 'templates/mixins.libsonnet';
local utils = import 'templates/utils.libsonnet';
local volumes = import 'templates/volumes.libsonnet';

{
  local Nightly = {
    frameworkPrefix: 'pt-20220314',
    tpuSettings+: {
      softwareVersion: 'tpu-vm-base',
    },
  },
  PyTorchTest:: common.PyTorchTest + Nightly,
  Functional:: mixins.Functional {
    schedule: '0 7 * * *',
    tpuSettings+: {
      preemptible: false,
    },
  },
  Convergence:: mixins.Convergence,
  PyTorchTpuVmMixin:: experimental.PyTorchTpuVmMixin {
    tpuSettings+: {
      softwareVersion: 'tpu-vm-base',
      tpuVmPytorchSetup: |||
        sudo pip install numpy
        sudo pip install torch_xla[tpuvm] -f https://storage.googleapis.com/tpu-pytorch/wheels/tpuvm/torch_xla-1.11-cp38-cp38-linux_x86_64.whl
        sudo pip install torch==1.11.0
        sudo pip install torchvision==0.12.0
        sudo pip install tensorflow-recommenders --no-deps
      |||,
    },
  },
  datasetsVolume: volumes.PersistentVolumeSpec {
    name: 'pytorch-datasets-claim',
    mountPath: '/datasets',
  },

  // DEPRECATED: Use PyTorchTpuVmMixin instead
  tpu_vm_latest_install: self.PyTorchTpuVmMixin.tpuSettings.tpuVmPytorchSetup,
}
