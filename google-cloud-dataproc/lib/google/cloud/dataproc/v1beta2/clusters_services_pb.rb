# Generated by the protocol buffer compiler.  DO NOT EDIT!
# Source: google/cloud/dataproc/v1beta2/clusters.proto for package 'google.cloud.dataproc.v1beta2'
# Original file comments:
# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


require 'grpc'
require 'google/cloud/dataproc/v1beta2/clusters_pb'

module Google
  module Cloud
    module Dataproc
      module V1beta2
        module ClusterController
          # The ClusterControllerService provides methods to manage clusters
          # of Compute Engine instances.
          class Service

            include GRPC::GenericService

            self.marshal_class_method = :encode
            self.unmarshal_class_method = :decode
            self.service_name = 'google.cloud.dataproc.v1beta2.ClusterController'

            # Creates a cluster in a project. The returned
            # [Operation.metadata][google.longrunning.Operation.metadata] will be
            # [ClusterOperationMetadata](https://cloud.google.com/dataproc/docs/reference/rpc/google.cloud.dataproc.v1beta2#clusteroperationmetadata).
            rpc :CreateCluster, CreateClusterRequest, Google::Longrunning::Operation
            # Updates a cluster in a project. The returned
            # [Operation.metadata][google.longrunning.Operation.metadata] will be
            # [ClusterOperationMetadata](https://cloud.google.com/dataproc/docs/reference/rpc/google.cloud.dataproc.v1beta2#clusteroperationmetadata).
            rpc :UpdateCluster, UpdateClusterRequest, Google::Longrunning::Operation
            # Deletes a cluster in a project. The returned
            # [Operation.metadata][google.longrunning.Operation.metadata] will be
            # [ClusterOperationMetadata](https://cloud.google.com/dataproc/docs/reference/rpc/google.cloud.dataproc.v1beta2#clusteroperationmetadata).
            rpc :DeleteCluster, DeleteClusterRequest, Google::Longrunning::Operation
            # Gets the resource representation for a cluster in a project.
            rpc :GetCluster, GetClusterRequest, Cluster
            # Lists all regions/\\{region}/clusters in a project.
            rpc :ListClusters, ListClustersRequest, ListClustersResponse
            # Gets cluster diagnostic information. The returned
            # [Operation.metadata][google.longrunning.Operation.metadata] will be
            # [ClusterOperationMetadata](https://cloud.google.com/dataproc/docs/reference/rpc/google.cloud.dataproc.v1beta2#clusteroperationmetadata).
            # After the operation completes,
            # [Operation.response][google.longrunning.Operation.response]
            # contains
            # [Empty][google.protobuf.Empty].
            rpc :DiagnoseCluster, DiagnoseClusterRequest, Google::Longrunning::Operation
          end

          Stub = Service.rpc_stub_class
        end
      end
    end
  end
end
