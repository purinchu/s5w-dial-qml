.PHONY: test

test:
	qmlscene --desktop --multisample --apptype gui --rhi vulkan test.qml
