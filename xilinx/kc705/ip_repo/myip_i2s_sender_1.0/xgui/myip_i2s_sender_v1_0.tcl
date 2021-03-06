# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  set Component_Name  [  ipgui::add_param $IPINST -name "Component_Name" -display_name {Component Name}]
  set_property tooltip {Component Name} ${Component_Name}
  #Adding Page
  set Page_0  [  ipgui::add_page $IPINST -name "Page 0" -display_name {Page 0}]
  set_property tooltip {Page 0} ${Page_0}
  set I2S_SENDER_TEST_DATA_WIDTH  [  ipgui::add_param $IPINST -name "I2S_SENDER_TEST_DATA_WIDTH" -parent ${Page_0} -display_name {I2s Sender Test Data Width}]
  set_property tooltip {I2s Sender Test Data Width} ${I2S_SENDER_TEST_DATA_WIDTH}


}

proc update_PARAM_VALUE.I2S_SENDER_TEST_DATA_WIDTH { PARAM_VALUE.I2S_SENDER_TEST_DATA_WIDTH } {
	# Procedure called to update I2S_SENDER_TEST_DATA_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.I2S_SENDER_TEST_DATA_WIDTH { PARAM_VALUE.I2S_SENDER_TEST_DATA_WIDTH } {
	# Procedure called to validate I2S_SENDER_TEST_DATA_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.I2S_SENDER_TEST_DATA_WIDTH { MODELPARAM_VALUE.I2S_SENDER_TEST_DATA_WIDTH PARAM_VALUE.I2S_SENDER_TEST_DATA_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.I2S_SENDER_TEST_DATA_WIDTH}] ${MODELPARAM_VALUE.I2S_SENDER_TEST_DATA_WIDTH}
}

