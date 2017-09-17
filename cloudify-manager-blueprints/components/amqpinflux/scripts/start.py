#!/usr/bin/env python

from os.path import join, dirname

from cloudify import ctx

ctx.download_resource(
    join('components', 'utils.py'),
    join(dirname(__file__), 'utils.py'))
import utils  # NOQA

runtime_props = ctx.instance.runtime_properties

ctx.logger.info('Starting AMQP-Influx Broker Service...')
utils.start_service(runtime_props['service_name'])
