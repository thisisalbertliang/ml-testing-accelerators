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

local experimental = import '../experimental.libsonnet';
local common = import 'common.libsonnet';
local mixins = import 'templates/mixins.libsonnet';
local timeouts = import 'templates/timeouts.libsonnet';
local tpus = import 'templates/tpus.libsonnet';
local utils = import 'templates/utils.libsonnet';

{
  local dist_resnet_pod50 = |||
    %s
    unset XRT_TPU_CONFIG
    export TPU_NAME=$(basename $(curl -s 'http://metadata.google.internal/computeMetadata/v1/instance/attributes/agent-node-name' -H 'Metadata-Flavor: Google'))
    echo $TPU_NAME

    cd /usr/share
    pip3 install tensorboardX google-cloud-storage
    python3 -m torch_xla.distributed.xla_dist --tpu=$TPU_NAME -- \
        python3 /usr/share/pytorch/xla/test/test_train_mp_imagenet.py \
        --num_epochs=90 --datadir=/datasets/imagenet --batch_size=128 --log_steps=200
  ||| % common.tpu_vm_latest_install,

  local resnet50_pod = common.PyTorchTest {
    modelName: 'resnet50-mp',
    command: utils.scriptCommand(
      dist_resnet_pod50
    ),
  },
  local v3_8 = {
    accelerator: tpus.v3_8,
  },
  local v3_32 = {
    accelerator: tpus.v3_32,
  },
  configs: [
    resnet50_pod + v3_32 + common.Functional + common.PyTorchTpuVmMixin,
  ],
}
