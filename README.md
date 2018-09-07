# Keepalived for Rancher HA

## Description

This is a CentOS based keepalived image. This image was built and customized specifically for use with Rancher 2.0 deployed in an HA 3-node K8s environment.

## Building

To build this image, simply run `docker build .` in the directory of the docker file.

## Configuration

### Important Notes

- A host mount of `/lib/modules` must be made into this container, as the container performs a check/load of the `ip_vs` kernel module on startup.
- VRRP must be enabled as an incoming iptables/firewalld rule, this container utilizes unicast to communicate between instances of keepalived. 

### Environment Variables

The following environment variables need to be set in order to allow the keepalived container to function properly.

#### Required Environment Variables

| Environment Variable | Description | Example |
|:--------------------:|:-----------:|:-------:|
| `VIP` | The Virtual IP Address for Rancher HA | `192.168.1.5` |
| `IFACE` | The Interface to Add/Remove the VIP from | `eth0` |
| `RANCHER_HOSTNAME` | The server-url for Rancher | `demo1.rancher.space` |
| `VRRP_PASS` | The password for VRRP (max 8 characters) | `mypaswrd` |
| `VR_ID` | The Virtual Router ID | `54` |
| `PEERS` | A semi-colon delimited list of peers | `192.168.1.10;192.168.1.11;192.168.1.12` |


#### Optional Environment Variables
| Environment Variable | Description | Example |
|:--------------------:|:-----------:|:-------:|
| `KEEPALIVED_OPTIONS` | Optional Keepalived Command Line Arguments | --log-detail |

#

Built by Chris Kim @ Rancher Labs

Loosely based on 
- [rht/ipfailover](registry.access.redhat.com/openshift3/ose-keepalived-ipfailover) 
- [osixia/docker-keepalived](https://github.com/osixia/docker-keepalived)